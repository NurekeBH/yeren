import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

export async function calendarRoutes(app: FastifyInstance) {
  app.get('/calendar', async (req) => {
    const Q = z.object({
      from: z.string().datetime().optional(),
      to: z.string().datetime().optional(),
      impact: z.enum(['low', 'medium', 'high']).optional(),
    });
    const { from, to, impact } = Q.parse(req.query);

    const where: string[] = [];
    const args: unknown[] = [];
    if (from) {
      args.push(from);
      where.push(`scheduled_at >= $${args.length}`);
    } else {
      // Әдепкі: БҮГІННЕН бастап (өткен күндер көрінбейді — «Барлығын көрсету» бүгіннен басталсын).
      where.push(`scheduled_at >= date_trunc('day', now())`);
    }
    if (to)   { args.push(to);   where.push(`scheduled_at <= $${args.length}`); }
    if (impact) { args.push(impact); where.push(`impact = $${args.length}`); }
    const sql = `select * from calendar_events ${where.length ? 'where ' + where.join(' and ') : ''}
                 order by scheduled_at asc limit 200`;
    const { rows } = await query(sql, args);
    return { events: rows };
  });

  // Ingest endpoint (Finnhub poller шақырады)
  app.post('/calendar/upsert', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const Body = z.object({
      external_id: z.string(),
      name: z.string(),
      currency: z.string(),
      impact: z.enum(['low', 'medium', 'high']),
      forecast: z.string().optional(),
      previous: z.string().optional(),
      actual: z.string().optional(),
      gold_impact_note: z.string().optional(),
      scheduled_at: z.string().datetime(),
    });
    const parsed = Body.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const e = parsed.data;
    const { rows } = await query(
      `insert into calendar_events (external_id, name, currency, impact, forecast, previous, actual, gold_impact_note, scheduled_at)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9)
       on conflict (external_id) do update set
         actual = excluded.actual,
         gold_impact_note = coalesce(excluded.gold_impact_note, calendar_events.gold_impact_note)
       returning *`,
      [e.external_id, e.name, e.currency, e.impact, e.forecast ?? null, e.previous ?? null,
        e.actual ?? null, e.gold_impact_note ?? null, e.scheduled_at],
    );
    return { event: rows[0] };
  });
}
