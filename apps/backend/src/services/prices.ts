import WebSocket from 'ws';

/// Бағаны сервер жағында ОРТАЛЫҚ жинау. Барлық клиент (app + alert) осыдан оқиды.
/// Провайдер абстракциясы: қазір PAXG (Binance, тегін/кілтсіз) + Yahoo (DXY/XAG/USOIL).
/// Кейін MT5 (Windows хост) сол PriceProvider интерфейсіне қосылады — қалғаны өзгермейді.

export type Quote = {
  symbol: string;
  price: number;
  deltaAbs: number;
  deltaPct: number;
  ts: string; // ISO
};

export interface PriceProvider {
  readonly name: string;
  fetchAll(): Promise<Quote[]>;
}

const TIMEOUT = 8000;

// ── XAU/USD — Binance PAXG/USDT 24h тикер (кілтсіз, mobile қолданатын дереккөз) ──
async function fetchXau(): Promise<Quote | null> {
  try {
    const res = await fetch('https://data-api.binance.vision/api/v3/ticker/24hr?symbol=PAXGUSDT', {
      signal: AbortSignal.timeout(TIMEOUT),
    });
    if (!res.ok) return null;
    const d = (await res.json()) as Record<string, string>;
    const price = Number(d.lastPrice);
    if (!Number.isFinite(price) || price <= 0) return null;
    const open = Number(d.openPrice);
    const deltaAbs = Number.isFinite(Number(d.priceChange)) ? Number(d.priceChange) : Number.isFinite(open) ? price - open : 0;
    const deltaPct = Number.isFinite(Number(d.priceChangePercent))
      ? Number(d.priceChangePercent)
      : open ? (deltaAbs / open) * 100 : 0;
    return { symbol: 'XAU/USD', price, deltaAbs, deltaPct, ts: new Date().toISOString() };
  } catch {
    return null;
  }
}

// ── DXY / XAG/USD / USOIL — Yahoo Finance chart ──
const YAHOO: Record<string, string> = {
  DXY: 'DX-Y.NYB',
  'XAG/USD': 'SI=F',
  USOIL: 'CL=F',
};

async function fetchYahoo(displaySymbol: string, yahooSym: string): Promise<Quote | null> {
  try {
    const res = await fetch(
      `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(yahooSym)}?interval=1m&range=1d`,
      { signal: AbortSignal.timeout(TIMEOUT), headers: { 'User-Agent': 'Mozilla/5.0 (ALTYN)' } },
    );
    if (!res.ok) return null;
    const data = (await res.json()) as {
      chart?: { result?: Array<{ meta?: { regularMarketPrice?: number; previousClose?: number; chartPreviousClose?: number } }> };
    };
    const meta = data.chart?.result?.[0]?.meta;
    const price = meta?.regularMarketPrice;
    const prev = meta?.previousClose ?? meta?.chartPreviousClose;
    if (price == null || prev == null) return null;
    const deltaAbs = price - prev;
    const deltaPct = prev === 0 ? 0 : (deltaAbs / prev) * 100;
    return { symbol: displaySymbol, price, deltaAbs, deltaPct, ts: new Date().toISOString() };
  } catch {
    return null;
  }
}

export const paxgYahooProvider: PriceProvider = {
  name: 'paxg+yahoo',
  async fetchAll() {
    const tasks = [fetchXau(), ...Object.entries(YAHOO).map(([sym, y]) => fetchYahoo(sym, y))];
    const results = await Promise.all(tasks);
    return results.filter((q): q is Quote => q != null);
  },
};

// ─────────────── Сервис: кэш + поллер ───────────────
let _provider: PriceProvider = paxgYahooProvider;
let _cache: Record<string, Quote> = {};
let _updatedAt: string | null = null;

export function setProvider(p: PriceProvider): void {
  _provider = p;
}

export function getQuotes(): Quote[] {
  return Object.values(_cache);
}

export function getQuotesMeta(): { provider: string; updatedAt: string | null; quotes: Quote[] } {
  return { provider: _provider.name, updatedAt: _updatedAt, quotes: Object.values(_cache) };
}

/// XAU/USD соңғы бағасы (alert поллері осыны оқиды — дисплеймен БІР дереккөз).
export function getXauPrice(): number | null {
  return _cache['XAU/USD']?.price ?? null;
}

export function startPricePoller(
  log: { info: (o: unknown, m?: string) => void; warn: (o: unknown, m?: string) => void },
  intervalMs = 6000,
): void {
  let busy = false;
  const tick = async (): Promise<void> => {
    if (busy) return;
    busy = true;
    try {
      const quotes = await _provider.fetchAll();
      if (quotes.length > 0) {
        const next: Record<string, Quote> = { ..._cache };
        for (const q of quotes) {
          // XAU-ды WS нақты уақытта жаңартып тұрса (≤15с) — REST мәнін елемейміз.
          if (q.symbol === 'XAU/USD') {
            const cur = next['XAU/USD'];
            if (cur && Date.now() - new Date(cur.ts).getTime() < 15_000) continue;
          }
          next[q.symbol] = q;
        }
        _cache = next;
        _updatedAt = new Date().toISOString();
      }
    } catch (err) {
      log.warn(err, 'price_poll_failed');
    } finally {
      busy = false;
    }
  };
  void tick();
  const timer = setInterval(() => void tick(), intervalMs);
  timer.unref?.();
  log.info(`Price poller started (provider=${_provider.name}, every ${intervalMs / 1000}s)`);
}

/// XAU/USD — Binance PAXG WebSocket (НАҚТЫ УАҚЫТ, ~1с). Кэшті тікелей жаңартады.
/// REST поллер XAU-ды тек WS өшіп қалғанда (≤15с ереже) толтырады. Авто-reconnect.
export function startBinanceWs(log: {
  info: (o: unknown, m?: string) => void;
  warn: (o: unknown, m?: string) => void;
}): void {
  let delay = 1000;
  const connect = (): void => {
    const ws = new WebSocket('wss://stream.binance.com:9443/ws/paxgusdt@ticker');
    ws.on('open', () => {
      delay = 1000;
      log.info('Binance WS connected (XAU/USD realtime)');
    });
    ws.on('message', (data: WebSocket.RawData) => {
      try {
        const j = JSON.parse(data.toString()) as { c?: string; p?: string; P?: string };
        const price = Number(j.c);
        if (!Number.isFinite(price) || price <= 0) return;
        _cache = {
          ..._cache,
          'XAU/USD': {
            symbol: 'XAU/USD',
            price,
            deltaAbs: Number(j.p) || 0,
            deltaPct: Number(j.P) || 0,
            ts: new Date().toISOString(),
          },
        };
        _updatedAt = new Date().toISOString();
      } catch {
        /* malformed frame — өткіземіз */
      }
    });
    const reconnect = (): void => {
      const t = setTimeout(connect, delay);
      t.unref?.();
      delay = Math.min(delay * 2, 30_000);
    };
    ws.on('close', reconnect);
    ws.on('error', (e: Error) => {
      log.warn(e, 'binance_ws_error');
      try {
        ws.close();
      } catch {
        /* */
      }
    });
  };
  connect();
}
