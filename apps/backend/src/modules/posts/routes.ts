import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

const PostCreate = z.object({
  provider_id: z.string().uuid(),
  text: z.string().min(1),
  image_url: z.string().url().optional(),
});

const CommentCreate = z.object({ text: z.string().min(1).max(1000) });

export async function postsRoutes(app: FastifyInstance) {
  // Провайдердің посттары (Published Ideas) + комментарийлер + лайк саны.
  app.get('/providers/:id/posts', async (req) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query(
      `select tp.id, tp.provider_id, tp.text, tp.image_url, tp.likes_count, tp.created_at,
              coalesce(c.comments, '[]'::json) as comments
         from trader_posts tp
         left join lateral (
           select json_agg(
                    json_build_object('author', cm.author, 'text', cm.text, 'created_at', cm.created_at)
                    order by cm.created_at
                  ) as comments
             from trader_post_comments cm
            where cm.post_id = tp.id
         ) c on true
        where tp.provider_id = $1
        order by tp.created_at desc`,
      [id],
    );
    return { posts: rows };
  });

  // Лайк (toggle).
  app.post('/posts/:id/like', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const existing = await query(
      'select 1 from trader_post_likes where post_id = $1 and user_id = $2',
      [id, req.userId],
    );
    if (existing.rows.length > 0) {
      await query('delete from trader_post_likes where post_id = $1 and user_id = $2', [id, req.userId]);
      await query('update trader_posts set likes_count = greatest(0, likes_count - 1) where id = $1', [id]);
      return { liked: false };
    }
    const exists = await query('select 1 from trader_posts where id = $1', [id]);
    if (exists.rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    await query(
      'insert into trader_post_likes (post_id, user_id) values ($1, $2) on conflict do nothing',
      [id, req.userId],
    );
    await query('update trader_posts set likes_count = likes_count + 1 where id = $1', [id]);
    return { liked: true };
  });

  // Комментарий қосу.
  app.post('/posts/:id/comments', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = CommentCreate.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const exists = await query('select 1 from trader_posts where id = $1', [id]);
    if (exists.rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    const u = await query<{ name: string }>(
      "select coalesce(nullif(name, ''), 'User') as name from users where id = $1",
      [req.userId],
    );
    const author = u.rows[0]?.name ?? 'User';
    const { rows } = await query(
      `insert into trader_post_comments (post_id, user_id, author, text)
       values ($1, $2, $3, $4) returning id, author, text, created_at`,
      [id, req.userId, author, parsed.data.text],
    );
    return { comment: rows[0] };
  });

  // Admin: пост құру.
  app.post('/posts', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const parsed = PostCreate.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const p = parsed.data;
    const { rows } = await query(
      'insert into trader_posts (provider_id, text, image_url) values ($1, $2, $3) returning *',
      [p.provider_id, p.text, p.image_url ?? null],
    );
    return { post: rows[0] };
  });
}
