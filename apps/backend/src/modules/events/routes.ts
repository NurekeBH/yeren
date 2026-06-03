import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

const EventCreate = z.object({
  type: z.enum(['masterclass', 'live_trade', 'webinar']),
  title: z.string().min(1),
  speaker: z.string().min(1),
  city: z.string().default('Online'),
  is_online: z.boolean().default(true),
  starts_at: z.string(), // ISO
  price: z.number().min(0).default(0),
  description: z.string().min(1),
  youtube_id: z.string().optional(),
  poster_url: z.string().url().optional(),
});

const Apply = z.object({
  name: z.string().min(1),
  phone: z.string().min(3),
  comment: z.string().optional(),
});

export async function eventsRoutes(app: FastifyInstance) {
  app.get('/events', async () => {
    const { rows } = await query('select * from events order by starts_at asc');
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

  // Admin: іс-шара құру + заявкалар тізімі
  app.post('/events', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const parsed = EventCreate.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const e = parsed.data;
    const { rows } = await query(
      `insert into events (type, title, speaker, city, is_online, starts_at, price, description, youtube_id, poster_url)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) returning *`,
      [e.type, e.title, e.speaker, e.city, e.is_online, e.starts_at, e.price, e.description, e.youtube_id ?? null, e.poster_url ?? null],
    );
    return { event: rows[0] };
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
