import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

// Қолдау хабарлары: пайдаланушы жібереді, админ көреді/шешеді.
export async function supportRoutes(app: FastifyInstance) {
  // Хабар жіберу (профильдегі Support формасынан).
  app.post('/support', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = z.object({ text: z.string().min(1).max(2000) }).safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { rows } = await query(
      `insert into support_messages (user_id, text) values ($1, $2) returning id, created_at`,
      [req.userId, parsed.data.text],
    );
    return { ok: true, message: rows[0] };
  });

  // Админ: барлық хабарлар.
  app.get('/support', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query(
      `select s.id, s.text, s.resolved, s.created_at, u.phone, u.name
       from support_messages s left join users u on u.id = s.user_id
       order by s.resolved asc, s.created_at desc limit 500`,
    );
    return { messages: rows };
  });

  // Админ: шешілді деп белгілеу.
  app.post('/support/:id/resolve', { onRequest: [app.requireAdmin] }, async (req) => {
    const id = (req.params as { id: string }).id;
    await query('update support_messages set resolved = true where id = $1', [id]);
    return { ok: true };
  });
}
