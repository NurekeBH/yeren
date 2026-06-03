import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

// Кітапхана каталогы (b-001, f-002, p-003...) — статик, клиентте.
// Серверде тек пайдаланушы деректері: сақтау / рейтинг / отзыв.
const UpsertBody = z.object({
  saved: z.boolean().optional(),
  rating: z.number().int().min(0).max(5).optional(),
  review: z.string().optional(),
});

export async function libraryRoutes(app: FastifyInstance) {
  // Пайдаланушының барлық кітапхана деректері (сақталғандар, бағалар, отзывтар)
  app.get('/library/me', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      'select item_id, saved, rating, review from library_user_data where user_id = $1',
      [req.userId],
    );
    return { items: rows };
  });

  // Сақтау / рейтинг / отзыв (upsert)
  app.put('/library/:itemId', { onRequest: [app.authenticate] }, async (req, reply) => {
    const itemId = (req.params as { itemId: string }).itemId;
    const parsed = UpsertBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;

    const set: string[] = [];
    const args: unknown[] = [req.userId, itemId];
    for (const [k, v] of Object.entries(d)) {
      if (v === undefined) continue;
      args.push(v);
      set.push(`${k} = $${args.length}`);
    }
    if (set.length === 0) return { ok: true };
    set.push('updated_at = now()');

    await query(
      `insert into library_user_data (user_id, item_id) values ($1, $2) on conflict do nothing`,
      [req.userId, itemId],
    );
    await query(
      `update library_user_data set ${set.join(', ')} where user_id = $1 and item_id = $2`,
      args,
    );
    return { ok: true };
  });

  // Бір элементтің барлық отзывтары (қоғамдық)
  app.get('/library/:itemId/reviews', async (req) => {
    const itemId = (req.params as { itemId: string }).itemId;
    const { rows } = await query(
      `select u.name, d.rating, d.review, d.updated_at
         from library_user_data d join users u on u.id = d.user_id
        where d.item_id = $1 and (d.review <> '' or d.rating > 0)
        order by d.updated_at desc limit 100`,
      [itemId],
    );
    return { reviews: rows };
  });
}
