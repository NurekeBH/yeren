import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';
import { sendEventPush } from '../../services/push.js';

const EventCreate = z.object({
  type: z.enum(['masterclass', 'live_trade', 'webinar']),
  title: z.string().min(1),
  speaker: z.string().min(1),
  city: z.string().default('Online'),
  is_online: z.boolean().default(true),
  // Парсталатын күн ғана (мусорды кесеміз), бірақ локаль ISO-ны да қабылдаймыз
  // (мобайл toIso8601String() offset-сіз жібереді) — клиенттер парс кезінде құламасын.
  starts_at: z.string().refine((s) => !Number.isNaN(Date.parse(s)), { message: 'invalid_date' }),
  price: z.number().min(0).default(0),
  description: z.string().min(1),
  youtube_id: z.string().optional(),
  poster_url: z.string().optional(), // өз хостингтен URL (жүктеу сәтсіз болса оқиға жоғалмауы үшін .url() қатаң емес)
});

const Apply = z.object({
  name: z.string().min(1),
  phone: z.string().min(3),
  comment: z.string().optional(),
});

export async function eventsRoutes(app: FastifyInstance) {
  // Қалалар autocomplete: теру → DB-ден ұсыныс (200+ қаланы скроллдамас үшін).
  // q берілсе — ILIKE сүзгі; әйтпесе алғашқы 30 (елі бойынша топтап).
  app.get('/cities', async (req) => {
    const q = ((req.query as { q?: string }).q ?? '').trim();
    if (q) {
      // name ЖӘНЕ aliases (латын/орыс транслитерация) бойынша іздейміз — мыс. «almaty»,
      // «aktobe», «Актобе» де табады. Аты басынан сәйкеспен басталғандар жоғары шығады.
      const { rows } = await query<{ name: string; country: string }>(
        `select name, country from cities
          where name ilike $1 or aliases ilike $1
          order by (name ilike $2) desc, (aliases ilike $2) desc, name limit 20`,
        [`%${q}%`, `${q}%`],
      );
      return { cities: rows };
    }
    const { rows } = await query<{ name: string; country: string }>(
      `select name, country from cities order by country = 'KZ' desc, name limit 30`,
    );
    return { cities: rows };
  });

  // Қоғамдық: тек РАСТАЛҒАН оқиғалар (провайдер қосқан pending-тер көрінбейді).
  app.get('/events', async () => {
    const { rows } = await query('select * from events where is_approved = true order by starts_at asc');
    return { events: rows };
  });

  app.get('/events/:id', async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query('select * from events where id = $1', [id]);
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    return { event: rows[0] };
  });

  // Заявка қалдыру (профильден автотолтыру — клиент жібереді)
  app.post('/events/:id/apply', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = Apply.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const exists = await query('select 1 from events where id = $1', [id]);
    if (exists.rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    const a = parsed.data;
    const { rows } = await query(
      `insert into event_applications (event_id, user_id, name, phone, comment)
       values ($1,$2,$3,$4,$5)
       on conflict (event_id, user_id) do update set name = excluded.name, phone = excluded.phone, comment = excluded.comment
       returning *`,
      [id, req.userId, a.name, a.phone, a.comment ?? ''],
    );
    return { application: rows[0] };
  });

  // Расталған трейдер/админ: іс-шара құру.
  // Админ қосса — бірден расталады + push. Провайдер (расталған трейдер) қосса —
  // pending (is_approved=false): админ растағанша app-та көрінбейді, push та жоқ.
  app.post('/events', { onRequest: [app.requireTrader] }, async (req, reply) => {
    const parsed = EventCreate.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const e = parsed.data;
    const adminRow = await query<{ is_admin: boolean }>('select is_admin from users where id = $1', [req.userId]);
    const isAdmin = adminRow.rows[0]?.is_admin === true;
    const { rows } = await query(
      `insert into events (type, title, speaker, city, is_online, starts_at, price, description, youtube_id, poster_url, is_approved, created_by)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12) returning *`,
      [e.type, e.title, e.speaker, e.city, e.is_online, e.starts_at, e.price, e.description,
       e.youtube_id ?? null, e.poster_url ?? null, isAdmin, req.userId],
    );
    // Push тек расталған (админ қосқан) оқиғаға — қолданушы сүзгілерін ескере отырып.
    if (isAdmin) {
      void sendEventPush(
        { city: e.city, price: e.price, is_online: e.is_online, type: e.type },
        { title: '📅 Жаңа іс-шара', body: e.title, data: { type: 'event', id: String(rows[0].id) } },
      );
    }
    return { event: rows[0], pending: !isAdmin };
  });

  // ── Админ: барлық оқиғалар (pending қоса) — модерация үшін ──
  app.get('/admin/events', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query(
      `select e.*, u.name as creator_name, u.phone as creator_phone
         from events e left join users u on u.id = e.created_by
        order by e.is_approved asc, e.starts_at asc`,
    );
    return { events: rows };
  });

  // ── Админ: провайдер қосқан оқиғаны растау (app-та көрінеді + push) ──
  app.post('/admin/events/:id/approve', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query<{ title: string; city: string; price: number; is_online: boolean; type: string }>(
      `update events set is_approved = true where id = $1 returning title, city, price, is_online, type`,
      [id],
    );
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    const ev = rows[0];
    void sendEventPush(
      { city: ev.city, price: Number(ev.price), is_online: ev.is_online, type: ev.type },
      { title: '📅 Жаңа іс-шара', body: ev.title, data: { type: 'event', id } },
    );
    return { ok: true };
  });

  // ── Провайдер: ӨЗ оқиғалары (растау күйімен) ──
  app.get('/provider/events', { onRequest: [app.requireTrader] }, async (req) => {
    const { rows } = await query(
      'select * from events where created_by = $1 order by starts_at asc',
      [req.userId],
    );
    return { events: rows };
  });

  // Провайдер: ӨЗ оқиғасын жою (растауға дейін немесе кейін).
  app.delete('/provider/events/:id', { onRequest: [app.requireTrader] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rowCount } = await query('delete from events where id = $1 and created_by = $2', [id, req.userId]);
    if (!rowCount) return reply.code(403).send({ error: 'not_owner' });
    return { ok: true };
  });

  // Админ: іс-шараны жою (немесе модерацияда қабылдамау).
  app.delete('/events/:id', { onRequest: [app.requireAdmin] }, async (req) => {
    await query('delete from events where id = $1', [(req.params as { id: string }).id]);
    return { ok: true };
  });

  app.get('/events/:id/applications', { onRequest: [app.requireAdmin] }, async (req) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query(
      'select * from event_applications where event_id = $1 order by created_at desc',
      [id],
    );
    return { applications: rows };
  });
}
