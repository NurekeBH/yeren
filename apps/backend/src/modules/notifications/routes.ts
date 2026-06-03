import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

export async function notificationsRoutes(app: FastifyInstance) {
  app.get('/notifications/prefs', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      `select * from notification_prefs where user_id = $1`,
      [req.userId],
    );
    return { prefs: rows[0] ?? null };
  });

  app.patch('/notifications/prefs', { onRequest: [app.authenticate] }, async (req, reply) => {
    const Body = z.object({
      signals_on: z.boolean().optional(),
      intel_on: z.boolean().optional(),
      calendar_on: z.boolean().optional(),
      ideas_on: z.boolean().optional(),
      review_on: z.boolean().optional(),
      academy_on: z.boolean().optional(),
      broker_on: z.boolean().optional(),
      streak_on: z.boolean().optional(),
      dnd_until_morning: z.boolean().optional(),
      expo_push_token: z.string().optional(),
    });
    const parsed = Body.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });

    const set: string[] = [];
    const args: unknown[] = [];
    for (const [k, v] of Object.entries(parsed.data)) {
      if (v === undefined) continue;
      args.push(v);
      set.push(`${k} = $${args.length}`);
    }
    if (set.length === 0) return { ok: true };
    args.push(req.userId);
    await query(
      `insert into notification_prefs (user_id) values ($${args.length}) on conflict do nothing`,
      [req.userId],
    );
    await query(
      `update notification_prefs set ${set.join(', ')} where user_id = $${args.length}`,
      args,
    );
    return { ok: true };
  });
}
