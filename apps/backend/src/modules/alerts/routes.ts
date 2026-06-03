import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

const AlertCreate = z.object({
  instrument: z.string().default('XAU/USD'),
  target_price: z.number(),
  pips: z.number().nullable().optional(),
  text: z.string().min(1),
  idea_id: z.string().uuid().nullable().optional(),
});

export async function alertsRoutes(app: FastifyInstance) {
  app.get('/alerts', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      'select * from price_alerts where user_id = $1 and active = true order by created_at desc',
      [req.userId],
    );
    return { alerts: rows };
  });

  app.post('/alerts', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = AlertCreate.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const a = parsed.data;
    const { rows } = await query(
      `insert into price_alerts (user_id, instrument, target_price, pips, text, idea_id)
       values ($1,$2,$3,$4,$5,$6) returning *`,
      [req.userId, a.instrument, a.target_price, a.pips ?? null, a.text, a.idea_id ?? null],
    );
    return { alert: rows[0] };
  });

  app.delete('/alerts/:id', { onRequest: [app.authenticate] }, async (req) => {
    const id = (req.params as { id: string }).id;
    await query('delete from price_alerts where id = $1 and user_id = $2', [id, req.userId]);
    return { ok: true };
  });
}
