import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

const TradeCreate = z.object({
  account_id: z.string().uuid().optional(),
  instrument: z.string().default('XAU/USD'),
  direction: z.enum(['buy', 'sell']),
  open_price: z.number(),
  close_price: z.number().optional(),
  lot: z.number(),
  pnl: z.number().optional(),
  rr_planned: z.number().optional(),
  rr_actual: z.number().optional(),
  setup_tag: z.string().optional(),
  session_tag: z.string().optional(),
  emotion: z.string().optional(),
  screenshot_url: z.string().url().optional(),
  notes: z.string().optional(),
  source: z.enum(['manual', 'mt_ea', 'ctrader_oauth', 'signal_copy']).default('manual'),
  opened_at: z.string().datetime(),
  closed_at: z.string().datetime().optional(),
});

export async function tradesRoutes(app: FastifyInstance) {
  app.get('/trades', { onRequest: [app.authenticate] }, async (req) => {
    const Q = z.object({
      account_id: z.string().uuid().optional(),
      limit: z.coerce.number().int().min(1).max(500).default(100),
    });
    const { account_id, limit } = Q.parse(req.query);
    const where: string[] = ['user_id = $1'];
    const args: unknown[] = [req.userId];
    if (account_id) { args.push(account_id); where.push(`account_id = $${args.length}`); }
    args.push(limit);
    const { rows } = await query(
      `select * from trades where ${where.join(' and ')} order by opened_at desc limit $${args.length}`,
      args,
    );
    return { trades: rows };
  });

  app.post('/trades', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = TradeCreate.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const t = parsed.data;
    const { rows } = await query(
      `insert into trades (user_id, account_id, instrument, direction, open_price, close_price, lot, pnl,
                           rr_planned, rr_actual, setup_tag, session_tag, emotion, screenshot_url, notes,
                           source, opened_at, closed_at)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
       returning *`,
      [req.userId, t.account_id ?? null, t.instrument, t.direction, t.open_price, t.close_price ?? null,
        t.lot, t.pnl ?? null, t.rr_planned ?? null, t.rr_actual ?? null, t.setup_tag ?? null,
        t.session_tag ?? null, t.emotion ?? null, t.screenshot_url ?? null, t.notes ?? null,
        t.source, t.opened_at, t.closed_at ?? null],
    );
    return { trade: rows[0] };
  });

  app.delete('/trades/:id', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rowCount } = await query(
      'delete from trades where id = $1 and user_id = $2',
      [id, req.userId],
    );
    if (!rowCount) return reply.code(404).send({ error: 'not_found' });
    return { ok: true };
  });

  // KPI: TZ §6.1 (Win Rate / Net P&L / Active signals / Streak)
  app.get('/trades/kpi', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query<{ total: string; wins: string; net_pnl: string }>(
      `select count(*)::text as total,
              count(*) filter (where pnl > 0)::text as wins,
              coalesce(sum(pnl), 0)::text as net_pnl
       from trades where user_id = $1 and closed_at is not null`,
      [req.userId],
    );
    const r = rows[0]!;
    const total = Number(r.total) || 0;
    const wins = Number(r.wins) || 0;
    return {
      total,
      win_rate: total === 0 ? 0 : wins / total,
      net_pnl: Number(r.net_pnl),
    };
  });
}
