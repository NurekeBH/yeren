import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

/// Админ-панель: статистика, қолданушыларды басқару (тізім, бұғаттау, рөл).
export async function adminRoutes(app: FastifyInstance) {
  // ── Жалпы статистика (overview) ──
  app.get('/admin/stats', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query<{
      users: string; blocked: string; traders: string; admins: string;
      new_7d: string; providers: string; signals: string; events: string;
      idea_sales: string; bonus_outstanding: string;
    }>(`
      select
        (select count(*) from users)::text as users,
        (select count(*) from users where is_blocked)::text as blocked,
        (select count(*) from users where is_verified_trader)::text as traders,
        (select count(*) from users where is_admin)::text as admins,
        (select count(*) from users where created_at >= now() - interval '7 days')::text as new_7d,
        (select count(*) from signal_providers)::text as providers,
        (select count(*) from signals)::text as signals,
        (select count(*) from events)::text as events,
        (select count(*) from signal_purchases)::text as idea_sales,
        (select coalesce(sum(bonus_balance),0) from users)::text as bonus_outstanding
    `);
    return { stats: rows[0] };
  });

  // ── Қолданушылар тізімі (іздеу + бет) ──
  app.get('/admin/users', { onRequest: [app.requireAdmin] }, async (req) => {
    const q = (req.query as { search?: string; limit?: string }) ?? {};
    const search = (q.search ?? '').trim();
    const limit = Math.min(Number(q.limit) || 100, 500);
    const args: unknown[] = [];
    let where = '';
    if (search) {
      args.push(`%${search}%`);
      where = `where phone ilike $1 or name ilike $1 or promo_code ilike $1`;
    }
    args.push(limit);
    const { rows } = await query(
      `select id, phone, name, city, is_admin, is_verified_trader, is_blocked,
              promo_code, bonus_balance, referral_count, created_at
         from users ${where}
        order by created_at desc
        limit $${args.length}`,
      args,
    );
    return { users: rows };
  });

  // ── Бұғаттау / ашу ──
  app.post('/admin/users/:id/block', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = z.object({ blocked: z.boolean() }).safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    if (id === req.userId) return reply.code(400).send({ error: 'cannot_block_self' });
    const { rowCount } = await query('update users set is_blocked = $1 where id = $2', [parsed.data.blocked, id]);
    if (!rowCount) return reply.code(404).send({ error: 'not_found' });
    return { ok: true };
  });

  // ── Рөл беру (admin / расталған трейдер) ──
  app.patch('/admin/users/:id/role', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = z
      .object({ is_admin: z.boolean().optional(), is_verified_trader: z.boolean().optional() })
      .safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const set: string[] = [];
    const args: unknown[] = [];
    for (const [k, v] of Object.entries(parsed.data)) {
      if (v === undefined) continue;
      args.push(v);
      set.push(`${k} = $${args.length}`);
    }
    if (set.length === 0) return { ok: true };
    args.push(id);
    const { rowCount } = await query(`update users set ${set.join(', ')} where id = $${args.length}`, args);
    if (!rowCount) return reply.code(404).send({ error: 'not_found' });
    return { ok: true };
  });
}
