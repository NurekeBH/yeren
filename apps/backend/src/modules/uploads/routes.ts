import type { FastifyInstance } from 'fastify';
import { query } from '../../db/client.js';
import { env } from '../../config/env.js';

/// Сурет жүктеу — ӨЗ Postgres DB-сіне (bytea), Supabase ЕМЕС.
/// POST /uploads → суретті сақтап, public URL қайтарады.
/// GET  /api/v1/uploads/:id → суретті береді (ашық).
export async function uploadsRoutes(app: FastifyInstance) {
  app.post('/uploads', { onRequest: [app.authenticate] }, async (req, reply) => {
    const file = await req.file();
    if (!file) return reply.code(400).send({ error: 'no_file' });
    const buf = await file.toBuffer();
    if (buf.length === 0) return reply.code(400).send({ error: 'empty_file' });
    const mime = file.mimetype || 'image/jpeg';

    const { rows } = await query<{ id: string }>(
      'insert into uploads (user_id, mime, data) values ($1, $2, $3) returning id',
      [req.userId, mime, buf],
    );
    // Абсолют URL: PUBLIC_URL болса — содан, әйтпесе сұраудан (trustProxy → https/host).
    const base = env.PUBLIC_URL || `${req.protocol}://${req.headers.host}`;
    return { url: `${base}/api/v1/uploads/${rows[0].id}` };
  });

  app.get('/uploads/:id', async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query<{ mime: string; data: Buffer }>(
      'select mime, data from uploads where id = $1',
      [id],
    );
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    reply.header('Content-Type', rows[0].mime);
    reply.header('Cache-Control', 'public, max-age=31536000, immutable');
    return reply.send(rows[0].data);
  });
}
