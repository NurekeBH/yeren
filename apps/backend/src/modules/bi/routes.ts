import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';
import { getOrSet } from '../../utils/cache.js';
import { engagement, finance, geo, content, cohorts, overview } from './metrics.js';

// Белый список событий — клиент произвольные строки в лог не пишет.
const TRACK_EVENTS = new Set([
  'app_open', 'view_course', 'view_signal', 'view_event', 'view_provider', 'open_paywall',
]);
const TrackBody = z.object({
  event: z.string().min(1).max(40),
  entity_type: z.string().max(20).optional(),
  entity_id: z.string().max(64).optional(),
});

const SpendBody = z.object({
  channel: z.enum(['instagram', 'google', 'tiktok', 'influencer', 'other']),
  campaign: z.string().max(120).optional(),
  amount_kzt: z.number().positive(),
  spent_on: z.string().refine((s) => !Number.isNaN(Date.parse(s)), 'bad date'),
  city: z.string().max(80).optional(),
  note: z.string().max(400).optional(),
});

export async function biRoutes(app: FastifyInstance) {
  // ── Ingestion: мобайл шлёт событие активности (лёгкое, fire-and-forget на клиенте) ──
  app.post('/track', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = TrackBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { event, entity_type, entity_id } = parsed.data;
    if (!TRACK_EVENTS.has(event)) return { ok: true }; // тихо игнорим неизвестные
    // city/country snapshot из профиля (для гео-воронок) одним INSERT...SELECT.
    await query(
      `insert into activity_events (user_id, event, entity_type, entity_id, city, country)
       select $1, $2, $3, $4, u.city, u.country from users u where u.id = $1`,
      [req.userId, event, entity_type ?? null, entity_id ?? null],
    );
    return { ok: true };
  });

  // ── BI read-endpoints (кэш: дашборд секунд-сайын жаңарудың қажеті жоқ) ──
  app.get('/admin/bi/overview', { onRequest: [app.requireAdmin] }, async () =>
    getOrSet('bi:overview', 60_000, overview));

  app.get('/admin/bi/engagement', { onRequest: [app.requireAdmin] }, async () =>
    getOrSet('bi:engagement', 60_000, engagement));

  app.get('/admin/bi/finance', { onRequest: [app.requireAdmin] }, async () =>
    getOrSet('bi:finance', 2 * 60_000, finance));

  app.get('/admin/bi/geo', { onRequest: [app.requireAdmin] }, async () =>
    getOrSet('bi:geo', 5 * 60_000, geo));

  app.get('/admin/bi/content', { onRequest: [app.requireAdmin] }, async () =>
    getOrSet('bi:content', 5 * 60_000, content));

  app.get('/admin/bi/cohorts', { onRequest: [app.requireAdmin] }, async () =>
    getOrSet('bi:cohorts', 10 * 60_000, cohorts));

  // ── Маркетинговые затраты (CAC) ──
  app.get('/admin/marketing-spend', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query(
      `select id, channel, campaign, amount_kzt, spent_on, city, note, created_at
         from marketing_spend order by spent_on desc, created_at desc limit 200`,
    );
    const total30 = rows
      .filter((r) => Date.parse(String(r.spent_on)) >= Date.now() - 30 * 86_400_000)
      .reduce((s, r) => s + Number(r.amount_kzt ?? 0), 0);
    return { items: rows, total_30d: total30 };
  });

  app.post('/admin/marketing-spend', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const parsed = SpendBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;
    const { rows } = await query(
      `insert into marketing_spend (channel, campaign, amount_kzt, spent_on, city, note)
       values ($1,$2,$3,$4,$5,$6) returning id, channel, campaign, amount_kzt, spent_on, city, note, created_at`,
      [d.channel, d.campaign ?? null, d.amount_kzt, d.spent_on, d.city ?? null, d.note ?? null],
    );
    return { item: rows[0] };
  });

  app.delete('/admin/marketing-spend/:id', { onRequest: [app.requireAdmin] }, async (req) => {
    await query('delete from marketing_spend where id = $1', [(req.params as { id: string }).id]);
    return { ok: true };
  });

  // ── AI-инсайты (лента карточек на «Обзоре») ──
  app.get('/admin/bi/insights', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query(
      `select id, severity, title, body, action, action_kind, meta, created_at
         from admin_insights where dismissed_at is null
        order by case severity when 'critical' then 0 when 'warning' then 1
                                when 'opportunity' then 2 else 3 end, created_at desc
        limit 30`,
    );
    return { insights: rows };
  });

  app.post('/admin/bi/insights/:id/dismiss', { onRequest: [app.requireAdmin] }, async (req) => {
    await query('update admin_insights set dismissed_at = now() where id = $1', [(req.params as { id: string }).id]);
    return { ok: true };
  });
}
