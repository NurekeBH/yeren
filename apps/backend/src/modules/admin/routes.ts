import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

/// Админ-панель: статистика, қолданушыларды басқару (тізім, бұғаттау, рөл).
export async function adminRoutes(app: FastifyInstance) {
  // ── Жалпы статистика (overview) ──
  app.get('/admin/stats', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query<Record<string, string>>(`
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
        (select coalesce(sum(bonus_balance),0) from users)::text as bonus_outstanding,
        -- ── Монетизация (бонус = ₸, 1:1) ──
        (select coalesce(sum(amount),0) from bonus_transactions where type = 'topup')::text as topup_total,
        (select count(*) from bonus_transactions where type = 'topup')::text as topup_count,
        (select coalesce(sum(amount),0) from bonus_transactions where type = 'topup' and created_at >= now() - interval '7 days')::text as topup_7d,
        (select coalesce(sum(amount),0) from bonus_transactions where amount > 0 and type in ('referral','signup'))::text as bonus_issued,
        (select count(*) from course_purchases)::text as course_sales,
        (select coalesce(sum(bonus_used),0) from course_purchases)::text as course_bonus,
        (select coalesce(sum(bonus_used),0) from signal_purchases)::text as signal_bonus,
        (select count(*) from exam_results)::text as exams_taken,
        (select count(*) from exam_results where passed)::text as exams_passed
    `);
    return { stats: rows[0] };
  });

  // ── Бонус транзакциялар журналы (соңғылары) ──
  app.get('/admin/bonus/transactions', { onRequest: [app.requireAdmin] }, async (req) => {
    const q = (req.query as { type?: string; limit?: string }) ?? {};
    const limit = Math.min(Number(q.limit) || 60, 300);
    const args: unknown[] = [];
    let where = '';
    if (q.type && q.type !== 'all') {
      args.push(q.type);
      where = `where t.type = $1`;
    }
    args.push(limit);
    const { rows } = await query(
      `select t.id, t.type, t.amount, t.ref, t.created_at, u.phone, u.name
         from bonus_transactions t
         join users u on u.id = t.user_id
         ${where}
        order by t.created_at desc
        limit $${args.length}`,
      args,
    );
    return { transactions: rows };
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
