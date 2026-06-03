import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query, tx } from '../../db/client.js';

export async function subscriptionRoutes(app: FastifyInstance) {
  app.get('/subscription', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      `select * from subscriptions where user_id = $1 order by created_at desc limit 1`,
      [req.userId],
    );
    return { subscription: rows[0] ?? { status: 'inactive', amount: 30000, currency: 'KZT' } };
  });

  // TZ.rtf override: чек жүктеу (Supabase Storage URL backend-ке келеді)
  app.post('/subscription/receipt', { onRequest: [app.authenticate] }, async (req, reply) => {
    const Body = z.object({ receipt_url: z.string().url() });
    const parsed = Body.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { rows } = await query(
      `update subscriptions
       set status = 'pending_review', receipt_url = $1, submitted_at = now()
       where user_id = $2 and status in ('inactive', 'expired')
       returning *`,
      [parsed.data.receipt_url, req.userId],
    );
    if (rows.length === 0) {
      // Жаңа subscription жасау
      const ins = await query(
        `insert into subscriptions (user_id, status, receipt_url, submitted_at)
         values ($1, 'pending_review', $2, now()) returning *`,
        [req.userId, parsed.data.receipt_url],
      );
      return { subscription: ins.rows[0] };
    }
    return { subscription: rows[0] };
  });

  // Admin: тексеру + 30 күнге активация
  app.post('/subscription/:id/approve', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const result = await tx(async (c) => {
      const { rows } = await c.query(
        `update subscriptions
         set status = 'active',
             approved_by = $1,
             activated_at = now(),
             expires_at = now() + interval '30 days'
         where id = $2 and status = 'pending_review'
         returning *`,
        [req.userId, id],
      );
      return rows[0];
    });
    if (!result) return reply.code(404).send({ error: 'not_found_or_not_pending' });
    return { subscription: result };
  });

  app.post('/subscription/:id/reject', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const Body = z.object({ notes: z.string().optional() });
    const parsed = Body.safeParse(req.body ?? {});
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { rows } = await query(
      `update subscriptions
       set status = 'inactive', notes = $1
       where id = $2 and status = 'pending_review'
       returning *`,
      [parsed.data.notes ?? null, id],
    );
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    return { subscription: rows[0] };
  });

  // Admin dashboard үшін pending тізімі
  app.get('/subscription/pending', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query(
      `select s.*, u.phone, u.name
       from subscriptions s join users u on u.id = s.user_id
       where s.status = 'pending_review' order by s.submitted_at desc`,
    );
    return { items: rows };
  });
}
