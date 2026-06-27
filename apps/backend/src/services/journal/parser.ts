// ════════════════════════ JOURNAL · MT4/MT5 STATEMENT PARSER ════════════════════════
// Exness/XM/IC Markets т.б. экспорттаған MT4/MT5 «Detailed Statement» (.html) немесе
// тарих (.csv) файлдарын оқып, RawOrder[] қайтарады (sync engine-мен бірдей пішін →
// сол upsertTrades-ты қайта қолданады). Тәуелсіз (қосымша npm пакеті жоқ), толерантты:
// бұзылған жолдарды өткізіп, warnings жинайды.
import type { RawOrder } from './sync_engine.js';

export interface ParseResult {
  orders: RawOrder[];
  warnings: string[];
  skipped: number;
  format: 'html' | 'csv';
}

export class StatementParseError extends Error {
  constructor(public code: string, message?: string) {
    super(message ?? code);
    this.name = 'StatementParseError';
  }
}

// ── Утилиталар ──
function decodeEntities(s: string): string {
  return s
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/gi, '&')
    .replace(/&lt;/gi, '<')
    .replace(/&gt;/gi, '>')
    .replace(/&quot;/gi, '"')
    .replace(/&#(\d+);/g, (_, d) => String.fromCharCode(Number(d)));
}

function stripTags(s: string): string {
  return decodeEntities(s.replace(/<[^>]*>/g, ' ')).replace(/\s+/g, ' ').trim();
}

/** Толерантты сан оқу: бос орын (мыңдық), үтір/нүкте ондық, минус/жақша. */
function num(raw: string | undefined): number {
  if (raw == null) return 0;
  let s = raw.replace(/\s/g, '').trim();
  if (!s || s === '-') return 0;
  const neg = /^\(.*\)$/.test(s); // (123.45) → теріс
  s = s.replace(/[()]/g, '');
  if (s.includes(',') && !s.includes('.')) s = s.replace(',', '.'); // үтір ондық
  else s = s.replace(/,/g, ''); // үтір мыңдық
  const n = Number(s);
  if (!Number.isFinite(n)) return 0;
  return neg ? -n : n;
}

/** MT уақыт пішімі «YYYY.MM.DD HH:MM:SS» → ISO. Әйтпесе Date.parse-қа сүйенеді. */
function toIso(raw: string | undefined): string | null {
  if (!raw) return null;
  const s = raw.trim();
  const m = s.match(/^(\d{4})\.(\d{2})\.(\d{2})\s+(\d{2}):(\d{2})(?::(\d{2}))?$/);
  if (m) {
    return `${m[1]}-${m[2]}-${m[3]}T${m[4]}:${m[5]}:${m[6] ?? '00'}Z`;
  }
  const t = Date.parse(s.replace(/\./g, '-'));
  return Number.isFinite(t) ? new Date(t).toISOString() : null;
}

const NON_TRADE = ['balance', 'deposit', 'withdrawal', 'credit', 'correction', 'commission', 'charge'];

function sideOf(type: string): 'buy' | 'sell' | null {
  const t = type.toLowerCase();
  if (t.includes('buy')) return 'buy';
  if (t.includes('sell')) return 'sell';
  return null;
}

// Тақырып ↔ өріс кескіні (lowercase ішінде болуы бойынша). Қайталанатын Time/Price-те
// біріншісі — ашылу, екіншісі — жабылу (MT5 орналасуы).
type Field =
  | 'ticket' | 'symbol' | 'type' | 'volume' | 'openTime' | 'openPrice'
  | 'sl' | 'tp' | 'closeTime' | 'closePrice' | 'commission' | 'swap' | 'profit';

function classifyHeader(cells: string[]): Partial<Record<Field, number>> {
  const map: Partial<Record<Field, number>> = {};
  let timeSeen = 0;
  let priceSeen = 0;
  cells.forEach((raw, i) => {
    const h = raw.toLowerCase();
    if (/(ticket|position|order|deal)\b/.test(h) && map.ticket == null) map.ticket = i;
    else if (h.includes('symbol') && map.symbol == null) map.symbol = i;
    else if (h.includes('type') && map.type == null) map.type = i;
    else if ((h.includes('volume') || h.includes('lots') || h.includes('size')) && map.volume == null) map.volume = i;
    else if (h.includes('s / l') || h.includes('s/l') || h === 'sl') map.sl = i;
    else if (h.includes('t / p') || h.includes('t/p') || h === 'tp') map.tp = i;
    else if (h.includes('commission')) map.commission = i;
    else if (h.includes('swap')) map.swap = i;
    else if (h.includes('profit')) map.profit = i;
    else if (h.includes('time')) {
      if (timeSeen++ === 0) map.openTime = i;
      else map.closeTime = i;
    } else if (h.includes('price')) {
      if (priceSeen++ === 0) map.openPrice = i;
      else map.closePrice = i;
    }
  });
  return map;
}

function rowToOrder(cells: string[], cols: Partial<Record<Field, number>>): RawOrder | null {
  const at = (f: Field): string | undefined => (cols[f] == null ? undefined : cells[cols[f]!]);
  const symbol = (at('symbol') ?? '').trim();
  const side = sideOf(at('type') ?? '');
  if (!symbol || !side) return null; // балланс/депозит жолдарын өткізу
  const ticket = (at('ticket') ?? '').trim();
  if (!ticket) return null;
  const openedAt = toIso(at('openTime'));
  if (!openedAt) return null;
  return {
    ticket,
    symbol,
    side,
    volume: num(at('volume')),
    openPrice: num(at('openPrice')),
    closePrice: cols.closePrice != null ? num(at('closePrice')) : null,
    sl: cols.sl != null ? num(at('sl')) : null,
    tp: cols.tp != null ? num(at('tp')) : null,
    commission: num(at('commission')),
    swap: num(at('swap')),
    profit: num(at('profit')),
    openedAt,
    closedAt: toIso(at('closeTime')),
    source: 'import',
  } as RawOrder & { source: string };
}

// ── HTML парсер (MT4/MT5 Detailed Statement) ──
function parseHtml(content: string): ParseResult {
  const warnings: string[] = [];
  const orders: RawOrder[] = [];
  let skipped = 0;

  const rows: string[][] = [];
  for (const trMatch of content.matchAll(/<tr[^>]*>([\s\S]*?)<\/tr>/gi)) {
    const cells: string[] = [];
    for (const tdMatch of trMatch[1].matchAll(/<t[dh][^>]*>([\s\S]*?)<\/t[dh]>/gi)) {
      cells.push(stripTags(tdMatch[1]));
    }
    if (cells.length) rows.push(cells);
  }

  // Тақырып жолын табу (symbol + profit бар).
  let cols: Partial<Record<Field, number>> | null = null;
  for (const cells of rows) {
    const joined = cells.join('|').toLowerCase();
    if (joined.includes('symbol') && joined.includes('profit')) {
      cols = classifyHeader(cells);
      continue;
    }
    if (!cols) continue;
    if (cells.length < 4) continue;
    const lower = cells.join(' ').toLowerCase();
    if (NON_TRADE.some((w) => lower.startsWith(w))) continue;
    const order = rowToOrder(cells, cols);
    if (order) orders.push(order);
    else skipped++;
  }

  if (!cols) throw new StatementParseError('no_trade_table', 'HTML statement-те сделкалар кестесі табылмады');
  if (skipped) warnings.push(`${skipped} жол өткізілді (сделка емес/толық емес)`);
  return { orders: dedupe(orders, warnings), warnings, skipped, format: 'html' };
}

// ── CSV/TSV парсер ──
function splitCsvLine(line: string): string[] {
  const delim = line.includes('\t') ? '\t' : line.includes(';') ? ';' : ',';
  const out: string[] = [];
  let cur = '';
  let inQ = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"') {
      if (inQ && line[i + 1] === '"') { cur += '"'; i++; }
      else inQ = !inQ;
    } else if (ch === delim && !inQ) {
      out.push(cur);
      cur = '';
    } else cur += ch;
  }
  out.push(cur);
  return out.map((c) => c.trim());
}

function parseCsv(content: string): ParseResult {
  const warnings: string[] = [];
  const orders: RawOrder[] = [];
  let skipped = 0;
  const lines = content.split(/\r?\n/).filter((l) => l.trim());

  let cols: Partial<Record<Field, number>> | null = null;
  for (const line of lines) {
    const cells = splitCsvLine(line);
    const joined = cells.join('|').toLowerCase();
    if (!cols) {
      if (joined.includes('symbol') && (joined.includes('profit') || joined.includes('type'))) {
        cols = classifyHeader(cells);
      }
      continue;
    }
    if (cells.length < 4) continue;
    const lower = cells.join(' ').toLowerCase();
    if (NON_TRADE.some((w) => lower.startsWith(w))) continue;
    const order = rowToOrder(cells, cols);
    if (order) orders.push(order);
    else skipped++;
  }

  if (!cols) throw new StatementParseError('no_header', 'CSV-де symbol/type тақырыбы табылмады');
  if (skipped) warnings.push(`${skipped} жол өткізілді (сделка емес/толық емес)`);
  return { orders: dedupe(orders, warnings), warnings, skipped, format: 'csv' };
}

/** Бір тикет екі рет кездессе (Deals+Positions) — соңғысын қалдырады. */
function dedupe(orders: RawOrder[], warnings: string[]): RawOrder[] {
  const byTicket = new Map<string, RawOrder>();
  for (const o of orders) byTicket.set(o.ticket, o);
  if (byTicket.size !== orders.length) {
    warnings.push(`${orders.length - byTicket.size} қайталанған тикет біріктірілді`);
  }
  return [...byTicket.values()];
}

/** Кіру нүктесі: мазмұн + (қалауынша) файл аты бойынша форматты анықтайды. */
export function parseStatement(content: string, filename?: string): ParseResult {
  if (!content || content.trim().length === 0) {
    throw new StatementParseError('empty_file', 'Файл бос');
  }
  const looksHtml = /<\s*(html|table|tr|td)\b/i.test(content) || /\.html?$/i.test(filename ?? '');
  return looksHtml ? parseHtml(content) : parseCsv(content);
}
