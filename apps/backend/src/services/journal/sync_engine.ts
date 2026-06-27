// ════════════════════════ JOURNAL · BACKGROUND SYNC ENGINE ════════════════════════
// MetaTrader investor-password (READ-ONLY) арқылы тарихты тартып, journal_trades-ке
// ҚАУІПСІЗ транзакциялы UPSERT жасайды. Кілт идея: upsert тек брокер ФАКТІЛЕРІН жаңартады,
// пайдаланушы аннотацияларын (trade_metadata: тег/скриншот/эмоция) ЕШҚАШАН өшірмейді
// (олар бөлек кестеде, тұрақты (account_id, ticket_id) кілт бойынша).
import type { PoolClient } from 'pg';
import { query, tx } from '../../db/client.js';
import { unwrapInvestorPassword } from './crypto.js';

// ── Типтер ──
export type SyncState = 'idle' | 'connecting' | 'fetching' | 'upserting' | 'ok' | 'error';

export interface RawOrder {
  ticket: string;
  symbol: string;
  side: 'buy' | 'sell';
  volume: number;
  openPrice: number;
  closePrice: number | null;
  sl?: number | null;
  tp?: number | null;
  commission: number;
  swap: number;
  profit: number;
  openedAt: string; // ISO
  closedAt: string | null; // ISO | null (ашық позиция)
  source?: string; // mt_sync | import | manual
}

export interface MtCredentials {
  login: string;
  server: string;
  platform: string; // mt4 | mt5
  investorPassword: string;
}

/** Тарих провайдері — прод-та нақты MT көпірі (MetaApi/MT bridge) болады. */
export interface MtHistoryProvider {
  fetchHistory(creds: MtCredentials, onState: (s: SyncState, note?: string) => void): Promise<RawOrder[]>;
}

export class MtSyncError extends Error {
  constructor(public code: string, message?: string) {
    super(message ?? code);
    this.name = 'MtSyncError';
  }
}

// ── Пип өлшемі (символ бойынша) → пипс есептеу ──
function pipSize(symbol: string): number {
  const s = symbol.toUpperCase();
  if (s.includes('XAU') || s.includes('GOLD')) return 0.1; // алтын
  if (s.includes('XAG') || s.includes('SILVER')) return 0.01;
  if (s.includes('JPY')) return 0.01; // йена жұптары
  if (s.startsWith('BTC') || s.startsWith('ETH')) return 1;
  return 0.0001; // FX мажорлар
}

export function computePips(symbol: string, side: 'buy' | 'sell', open: number, close: number | null): number | null {
  if (close == null) return null;
  const diff = side === 'buy' ? close - open : open - close;
  return Number((diff / pipSize(symbol)).toFixed(2));
}

// ════════════ Транзакциялы UPSERT (синхрон ДА, импорт ТА қолданады) ════════════
// trade_metadata-ға ТИМЕЙДІ → қолданушы аннотациялары сақталады.
export async function upsertTrades(
  accountId: string,
  userId: string,
  orders: RawOrder[],
): Promise<{ inserted: number; updated: number }> {
  if (orders.length === 0) return { inserted: 0, updated: 0 };
  return tx(async (c: PoolClient) => {
    let inserted = 0;
    let updated = 0;
    for (const o of orders) {
      const pips = computePips(o.symbol, o.side, o.openPrice, o.closePrice);
      const res = await c.query<{ inserted: boolean }>(
        `insert into journal_trades
           (account_id, user_id, ticket_id, symbol, side, volume, open_price, close_price,
            sl, tp, commission, swap, profit, pips, opened_at, closed_at, source)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)
         on conflict (account_id, ticket_id) do update set
           symbol = excluded.symbol, side = excluded.side, volume = excluded.volume,
           open_price = excluded.open_price, close_price = excluded.close_price,
           sl = excluded.sl, tp = excluded.tp, commission = excluded.commission,
           swap = excluded.swap, profit = excluded.profit, pips = excluded.pips,
           opened_at = excluded.opened_at, closed_at = excluded.closed_at, updated_at = now()
         returning (xmax = 0) as inserted`,
        [
          accountId, userId, o.ticket, o.symbol, o.side, o.volume, o.openPrice, o.closePrice,
          o.sl ?? null, o.tp ?? null, o.commission, o.swap, o.profit, pips, o.openedAt, o.closedAt,
          o.source ?? 'mt_sync',
        ] as never[],
      );
      if (res.rows[0]?.inserted) inserted++;
      else updated++;
    }
    return { inserted, updated };
  });
}

// ── Аккаунт sync_state-ін жаңарту (realtime күй симуляциясы) ──
async function setState(accountId: string, state: SyncState, error: string | null = null): Promise<void> {
  await query(
    `update trading_accounts set sync_state = $2, sync_error = $3,
        last_synced_at = case when $2 = 'ok' then now() else last_synced_at end
      where id = $1`,
    [accountId, state, error],
  );
}

const SYNC_TIMEOUT_MS = 30_000;

function withTimeout<T>(p: Promise<T>, ms: number): Promise<T> {
  return Promise.race([
    p,
    new Promise<T>((_, reject) => setTimeout(() => reject(new MtSyncError('server_timeout', 'MT server timed out')), ms)),
  ]);
}

export interface SyncResult {
  ok: boolean;
  state: SyncState;
  inserted: number;
  updated: number;
  error?: string;
}

/**
 * Аккаунтты синхрондау: investor паролін шешіп, провайдерден тарихты тартып,
 * транзакциялы upsert жасайды. Барлық қателер (timeout/байланыс/парсинг) ұсталады
 * → sync_state='error' + sync_error, лақтырмайды (background-safe).
 */
export async function syncAccount(accountId: string, provider: MtHistoryProvider): Promise<SyncResult> {
  const { rows } = await query<{
    id: string;
    user_id: string;
    login: string;
    server: string;
    platform: string;
    investor_password_cipher: string | null;
  }>(
    `select id, user_id, login, server, platform, investor_password_cipher
       from trading_accounts where id = $1 and removed_at is null`,
    [accountId],
  );
  const acc = rows[0];
  if (!acc) return { ok: false, state: 'error', inserted: 0, updated: 0, error: 'account_not_found' };
  if (!acc.investor_password_cipher) {
    await setState(accountId, 'error', 'no_credentials');
    return { ok: false, state: 'error', inserted: 0, updated: 0, error: 'no_credentials' };
  }

  try {
    await setState(accountId, 'connecting');
    const creds: MtCredentials = {
      login: acc.login,
      server: acc.server,
      platform: acc.platform,
      investorPassword: unwrapInvestorPassword(acc.investor_password_cipher),
    };

    const orders = await withTimeout(
      provider.fetchHistory(creds, (s) => {
        // Провайдер байланыс күйін хабарлайды (connecting/fetching) → DB-ге жазамыз.
        void setState(accountId, s);
      }),
      SYNC_TIMEOUT_MS,
    );

    await setState(accountId, 'upserting');
    const { inserted, updated } = await upsertTrades(accountId, acc.user_id, orders);

    await setState(accountId, 'ok');
    return { ok: true, state: 'ok', inserted, updated };
  } catch (err) {
    const code = err instanceof MtSyncError ? err.code : 'sync_failed';
    await setState(accountId, 'error', code);
    return { ok: false, state: 'error', inserted: 0, updated: 0, error: code };
  }
}

/**
 * Әдепкі провайдер: нақты MT көпірі (MetaApi/EA bridge) бапталмаған.
 * Жалған дерек ЖАСАМАЙДЫ — таза қателік қайтарады (қолданушы статементті импорттай алады).
 * Нақты интеграция қосылғанда осы класс ауыстырылады.
 */
export class UnconfiguredMtProvider implements MtHistoryProvider {
  async fetchHistory(_creds: MtCredentials, onState: (s: SyncState) => void): Promise<RawOrder[]> {
    onState('connecting');
    // Прод-та осы жерде MetaApi.connect(login, server, investorPassword) болады.
    throw new MtSyncError('mt_bridge_not_configured', 'MetaTrader bridge is not configured on this server');
  }
}

/** Сервердің әдепкі провайдері (нақты интеграция қосылғанда ауыстырылады). */
export const defaultMtProvider: MtHistoryProvider = new UnconfiguredMtProvider();
