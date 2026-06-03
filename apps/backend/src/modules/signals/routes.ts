import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

const SignalCreate = z.object({
  pair: z.string().default('XAU/USD'),
  direction: z.enum(['buy', 'sell']),
  entry_from: z.number(),
  entry_to: z.number(),
  tp1: z.number(),
  tp2: z.number().optional(),
  tp3: z.number().optional(),
  sl: z.number(),
  rr: z.number(),
  confidence: z.number().int().min(0).max(100),
  screenshot_url: z.string().url().optional(),
  analysis: z.string().min(1),
  provider_id: z.string().uuid().optional(),
  source: z.enum(['admin', 'telegram_bot']).default('admin'),
  source_message_id: z.string().optional(),
});

const SignalClose = z.object({
  status: z.enum(['closed_tp1', 'closed_tp2', 'closed_tp3', 'closed_sl']),
  result_pips: z.number().int(),
});

export async function signalsRoutes(app: FastifyInstance) {
  app.get('/signals', async () => {
    const { rows } = await query(`select * from signals order by published_at desc limit 200`);
    return { signals: rows };
  });

  app.get('/signals/:id', async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query('select * from signals where id = $1', [id]);
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    return { signal: rows[0] };
  });

  // Admin: жариялау (TZ §10.3)
  app.post('/signals', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const parsed = SignalCreate.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const s = parsed.data;
    const { rows } = await query(
      `insert into signals (pair, direction, entry_from, entry_to, tp1, tp2, tp3, sl, rr, confidence,
                            screenshot_url, analysis, provider_id, source, source_message_id)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
       returning *`,
      [s.pair, s.direction, s.entry_from, s.entry_to, s.tp1, s.tp2 ?? null, s.tp3 ?? null, s.sl, s.rr,
        s.confidence, s.screenshot_url ?? null, s.analysis, s.provider_id ?? null, s.source, s.source_message_id ?? null],
    );
    return { signal: rows[0] };
  });

  // Admin: жабу
  app.post('/signals/:id/close', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = SignalClose.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { rows } = await query(
      `update signals set status = $1, result_pips = $2, closed_at = now() where id = $3 returning *`,
      [parsed.data.status, parsed.data.result_pips, id],
    );
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    return { signal: rows[0] };
  });

  // Provider stats (TZ §10.4)
  app.get('/signals/stats', async () => {
    const { rows } = await query<{
      total: string; wins: string; losses: string; sum_win: string; sum_loss: string; avg_rr: string;
    }>(`
      with closed as (
        select * from signals where status <> 'active'
      )
      select
        count(*)::text as total,
        count(*) filter (where status in ('closed_tp1','closed_tp2','closed_tp3'))::text as wins,
        count(*) filter (where status = 'closed_sl')::text as losses,
        coalesce(sum(result_pips) filter (where result_pips > 0), 0)::text as sum_win,
        coalesce(sum(abs(result_pips)) filter (where result_pips < 0), 0)::text as sum_loss,
        coalesce(avg(rr), 0)::text as avg_rr
      from closed
    `);
    const r = rows[0]!;
    const total = Number(r.total) || 0;
    const wins = Number(r.wins) || 0;
    const losses = Number(r.losses) || 0;
    const sumWin = Number(r.sum_win) || 0;
    const sumLoss = Number(r.sum_loss) || 0;
    return {
      total,
      wins,
      losses,
      win_rate: total === 0 ? 0 : wins / total,
      profit_factor: sumLoss === 0 ? null : sumWin / sumLoss,
      avg_rr: Number(r.avg_rr),
    };
  });
}
