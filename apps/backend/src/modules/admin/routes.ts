import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';
import { ensureProviderProfile, removeProviderProfile } from '../../services/provider_profile.js';
import { getOrSet } from '../../utils/cache.js';

/// Админ-панель: статистика, қолданушыларды басқару (тізім, бұғаттау, рөл).
export async function adminRoutes(app: FastifyInstance) {
  // ── Жалпы статистика (overview) ──
  app.get('/admin/stats', { onRequest: [app.requireAdmin] }, async () => {
    // ПЕРФОРМАНС: ~22 субзапроса (толық сканер) — дашборд секунд-сайын жаңарудың қажеті жоқ. 60с кэш.
    const stats = await getOrSet('admin_stats', 60_000, async () => {
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
        (select coalesce(sum(amount),0) from bonus_transactions where type = 'referral')::text as referral_total,
        (select count(*) from bonus_transactions where type = 'referral')::text as referral_count,
        (select coalesce(sum(amount),0) from bonus_transactions where type = 'signup')::text as signup_total,
        (select count(*) from course_purchases)::text as course_sales,
        (select coalesce(sum(bonus_used),0) from course_purchases)::text as course_bonus,
        (select coalesce(sum(bonus_used),0) from signal_purchases)::text as signal_bonus,
        (select count(*) from exam_results)::text as exams_taken,
        (select count(*) from exam_results where passed)::text as exams_passed
    `);
      return rows[0];
    });
    return { stats };
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

  // ── Назар керек элементтер саны (nav белгілері) ──
  // Әр категорияда қанша «әрекет күтуде» — растау/қарау керек.
  app.get('/admin/pending-counts', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query<Record<string, string>>(`
      select
        (select count(*) from trader_applications where status = 'pending')::text as applications,
        (select count(*) from events where is_approved = false)::text as events,
        (select count(*) from post_reports where status = 'open')::text as reports,
        (select count(*) from support_messages where resolved = false)::text as support
    `);
    const r = rows[0] ?? {};
    return {
      applications: Number(r.applications ?? 0),
      events: Number(r.events ?? 0),
      reports: Number(r.reports ?? 0),
      support: Number(r.support ?? 0),
    };
  });

  // ── Ел бойынша бөлініс (жаңа тіл қосу шешімі үшін) ──
  // ISO-2 коды + саны + үлесі. Бос (ескі тіркелулер) — 'unknown'.
  app.get('/admin/stats/countries', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query<{ country: string; count: string }>(`
      select coalesce(nullif(country, ''), 'unknown') as country, count(*)::text as count
        from users
       group by 1
       order by count(*) desc
    `);
    const total = rows.reduce((s, r) => s + Number(r.count), 0) || 1;
    return {
      total,
      countries: rows.map((r) => ({ country: r.country, count: Number(r.count), pct: Math.round((Number(r.count) / total) * 100) })),
    };
  });

  // ── Тіркелу аналитикасы (маркетинг/перформанс) ──
  // Бүгін/кеше/7к/30к/барлығы + соңғы 30 күннің күнделікті сериясы (график үшін).
  app.get('/admin/stats/registrations', { onRequest: [app.requireAdmin] }, async () => {
    const data = await getOrSet('admin_registrations', 5 * 60_000, async () => {
    // summary мен series ҚАТАР (тәуелсіз).
    const [summary, series] = await Promise.all([
      query<Record<string, string>>(`
        select
          (select count(*) from users where created_at >= date_trunc('day', now()))::text as today,
          (select count(*) from users where created_at >= date_trunc('day', now()) - interval '1 day'
                                        and created_at <  date_trunc('day', now()))::text as yesterday,
          (select count(*) from users where created_at >= date_trunc('day', now()) - interval '7 days')::text as last_7d,
          (select count(*) from users where created_at >= date_trunc('day', now()) - interval '30 days')::text as last_30d,
          (select count(*) from users)::text as total
      `),
      // Range-join (date_trunc(column) ОРНЫНА) — users_created_at_idx индексін қолданады (sargable).
      query<{ day: string; count: string }>(`
        with days as (
          select generate_series(date_trunc('day', now()) - interval '29 days', date_trunc('day', now()), interval '1 day') as d
        )
        select to_char(days.d, 'YYYY-MM-DD') as day, count(u.id)::text as count
          from days
          left join users u on u.created_at >= days.d and u.created_at < days.d + interval '1 day'
         group by days.d order by days.d
      `),
    ]);
    const r = summary.rows[0] ?? {};
    return {
      today: Number(r.today ?? 0),
      yesterday: Number(r.yesterday ?? 0),
      last_7d: Number(r.last_7d ?? 0),
      last_30d: Number(r.last_30d ?? 0),
      total: Number(r.total ?? 0),
      daily: series.rows.map((s) => ({ day: s.day, count: Number(s.count) })),
    };
    });
    return data;
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
      `select id, phone, name, city, country, is_admin, is_verified_trader, is_blocked,
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
    // Админ өзін-өзі админдіктен айыра алмайды (өзін құлыптап қалмауы үшін).
    if (id === req.userId && parsed.data.is_admin === false) {
      return reply.code(400).send({ error: 'cannot_demote_self' });
    }
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
    // Провайдер ролі: берілсе — профиль авто-жасалады, алынса — өшіріледі.
    if (parsed.data.is_verified_trader === true) {
      await ensureProviderProfile((sql, p) => query(sql, p as never[]), id);
    } else if (parsed.data.is_verified_trader === false) {
      await removeProviderProfile((sql, p) => query(sql, p as never[]), id);
    }
    return { ok: true };
  });
}
