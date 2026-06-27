// ════════════════════════ JOURNAL · ANALYTICS ════════════════════════
// journal_trades (+ trade_metadata эмоциялар үшін) бойынша көрсеткіштер:
// Win Rate, Profit Factor, Expected Value (expectancy), GitHub-стиль күнтізбе торы,
// «Emotions vs Profit» корреляция матрицасы (Postgres corr() = Пирсон).
// Таза P&L әр сделкада: profit + commission + swap.
import { query } from '../../db/client.js';

const NET = '(t.profit + t.commission + t.swap)';
// account фильтрі: $2 null болса — барлық аккаунттар.
const SCOPE = 't.user_id = $1 and ($2::uuid is null or t.account_id = $2) and t.closed_at is not null';

export interface CoreStats {
  closed: number;
  wins: number;
  losses: number;
  breakeven: number;
  win_rate: number; // 0..1
  gross_profit: number;
  gross_loss: number; // теріс
  net_profit: number;
  profit_factor: number | null; // gross_profit / |gross_loss|, шығынсыз → null
  avg_win: number;
  avg_loss: number; // теріс
  expectancy: number; // орташа таза P&L / сделка (Expected Value)
  expectancy_r: number | null; // RR-мен өрнектелген күтілім (avg_win/|avg_loss| негізінде)
  best: number;
  worst: number;
  total_volume: number;
}

export async function coreStats(userId: string, accountId: string | null): Promise<CoreStats> {
  const { rows } = await query<Record<string, string>>(
    `select
        count(*)::int                                              as closed,
        count(*) filter (where ${NET} > 0)::int                    as wins,
        count(*) filter (where ${NET} < 0)::int                    as losses,
        count(*) filter (where ${NET} = 0)::int                    as breakeven,
        coalesce(sum(${NET}) filter (where ${NET} > 0), 0)         as gross_profit,
        coalesce(sum(${NET}) filter (where ${NET} < 0), 0)         as gross_loss,
        coalesce(sum(${NET}), 0)                                   as net_profit,
        coalesce(avg(${NET}) filter (where ${NET} > 0), 0)         as avg_win,
        coalesce(avg(${NET}) filter (where ${NET} < 0), 0)         as avg_loss,
        coalesce(max(${NET}), 0)                                   as best,
        coalesce(min(${NET}), 0)                                   as worst,
        coalesce(sum(t.volume), 0)                                 as total_volume
       from journal_trades t
      where ${SCOPE}`,
    [userId, accountId],
  );
  const r = rows[0];
  const n = (k: string) => Number(r[k] ?? 0);
  const closed = n('closed');
  const grossProfit = n('gross_profit');
  const grossLoss = n('gross_loss');
  const avgWin = n('avg_win');
  const avgLoss = n('avg_loss');
  const winRate = closed ? n('wins') / closed : 0;
  return {
    closed,
    wins: n('wins'),
    losses: n('losses'),
    breakeven: n('breakeven'),
    win_rate: Number(winRate.toFixed(4)),
    gross_profit: round2(grossProfit),
    gross_loss: round2(grossLoss),
    net_profit: round2(n('net_profit')),
    profit_factor: grossLoss !== 0 ? Number((grossProfit / Math.abs(grossLoss)).toFixed(2)) : null,
    avg_win: round2(avgWin),
    avg_loss: round2(avgLoss),
    expectancy: closed ? round2(n('net_profit') / closed) : 0,
    expectancy_r:
      avgLoss !== 0 ? Number((winRate * (avgWin / Math.abs(avgLoss)) - (1 - winRate)).toFixed(3)) : null,
    best: round2(n('best')),
    worst: round2(n('worst')),
    total_volume: round2(n('total_volume')),
  };
}

export interface CalendarCell {
  day: string; // YYYY-MM-DD
  pnl: number;
  trades: number;
}

/** GitHub-стиль жылулық тор: күн бойынша таза P&L + сделка саны. */
export async function calendarGrid(
  userId: string,
  accountId: string | null,
  from: string | null,
  to: string | null,
): Promise<CalendarCell[]> {
  const { rows } = await query<{ day: string; pnl: string; trades: number }>(
    `select to_char((t.closed_at at time zone 'UTC')::date, 'YYYY-MM-DD') as day,
            sum(${NET}) as pnl,
            count(*)::int as trades
       from journal_trades t
      where ${SCOPE}
        and ($3::date is null or t.closed_at >= $3)
        and ($4::date is null or t.closed_at < ($4::date + 1))
      group by 1 order by 1`,
    [userId, accountId, from, to],
  );
  return rows.map((r) => ({ day: r.day, pnl: round2(Number(r.pnl)), trades: r.trades }));
}

export interface EmotionRow {
  emotion: string;
  trades: number;
  pnl: number;
  avg_pnl: number;
  win_rate: number;
}
export interface EmotionsMatrix {
  rows: EmotionRow[];
  correlation: number | null; // эмоция реті (1..5) мен P&L Пирсон корреляциясы
}

const EMOTION_ORD = `case m.emotion when '😤' then 1 when '😬' then 2 when '😐' then 3 when '🙂' then 4 when '😌' then 5 end`;

/** «Emotions vs Profit» — эмоция бойынша P&L бөлінісі + Пирсон корреляциясы. */
export async function emotionsMatrix(userId: string, accountId: string | null): Promise<EmotionsMatrix> {
  const grouped = await query<{ emotion: string; trades: number; pnl: string; avg_pnl: string; wins: number }>(
    `select m.emotion,
            count(*)::int as trades,
            sum(${NET}) as pnl,
            avg(${NET}) as avg_pnl,
            count(*) filter (where ${NET} > 0)::int as wins
       from journal_trades t
       join trade_metadata m on m.account_id = t.account_id and m.ticket_id = t.ticket_id
      where ${SCOPE} and m.emotion is not null and m.emotion <> ''
      group by m.emotion order by m.emotion`,
    [userId, accountId],
  );
  const corr = await query<{ c: string | null }>(
    `select corr(${EMOTION_ORD}, ${NET}) as c
       from journal_trades t
       join trade_metadata m on m.account_id = t.account_id and m.ticket_id = t.ticket_id
      where ${SCOPE} and m.emotion is not null and m.emotion <> ''`,
    [userId, accountId],
  );
  return {
    rows: grouped.rows.map((r) => ({
      emotion: r.emotion,
      trades: r.trades,
      pnl: round2(Number(r.pnl)),
      avg_pnl: round2(Number(r.avg_pnl)),
      win_rate: r.trades ? Number((r.wins / r.trades).toFixed(4)) : 0,
    })),
    correlation: corr.rows[0]?.c == null ? null : Number(Number(corr.rows[0].c).toFixed(3)),
  };
}

export interface BreakdownRow {
  key: string;
  trades: number;
  pnl: number;
  win_rate: number;
}

/** Setup/session бойынша бөлініс (trade_metadata тегтері). */
export async function tagBreakdown(
  userId: string,
  accountId: string | null,
  field: 'setup_tag' | 'session_tag',
): Promise<BreakdownRow[]> {
  const { rows } = await query<{ key: string; trades: number; pnl: string; wins: number }>(
    `select m.${field} as key, count(*)::int as trades, sum(${NET}) as pnl,
            count(*) filter (where ${NET} > 0)::int as wins
       from journal_trades t
       join trade_metadata m on m.account_id = t.account_id and m.ticket_id = t.ticket_id
      where ${SCOPE} and m.${field} is not null and m.${field} <> ''
      group by m.${field} order by sum(${NET}) desc`,
    [userId, accountId],
  );
  return rows.map((r) => ({
    key: r.key,
    trades: r.trades,
    pnl: round2(Number(r.pnl)),
    win_rate: r.trades ? Number((r.wins / r.trades).toFixed(4)) : 0,
  }));
}

function round2(n: number): number {
  return Math.round(n * 100) / 100;
}
