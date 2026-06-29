import type { FastifyInstance } from 'fastify';
import { query } from '../../db/client.js';
import { env } from '../../config/env.js';

/// Сурет жүктеу — ӨЗ Postgres DB-сіне (bytea), Supabase ЕМЕС.
/// POST /uploads → суретті сақтап, public URL қайтарады.
/// GET  /api/v1/uploads/:id → суретті береді (ашық).

/// Тек нақты сурет түрлеріне рұқсат — әйтпесе SVG/HTML «суретін» жүктеп, GET кезінде
/// сол origin-де (altyn.social) script орындалуы мүмкін еді (stored XSS → токен ұрлау).
const ALLOWED_MIME = new Set(['image/jpeg', 'image/png', 'image/webp', 'image/gif']);

/// Файл мазмұнының алғашқы байттары шынымен сурет пе (магиялық сигнатура).
function isRealImage(b: Buffer): boolean {
  if (b.length < 12) return false;
  const jpeg = b[0] === 0xff && b[1] === 0xd8 && b[2] === 0xff;
  const png = b[0] === 0x89 && b[1] === 0x50 && b[2] === 0x4e && b[3] === 0x47;
  const gif = b[0] === 0x47 && b[1] === 0x49 && b[2] === 0x46;
  const webp = b.subarray(0, 4).toString('ascii') === 'RIFF' && b.subarray(8, 12).toString('ascii') === 'WEBP';
  return jpeg || png || gif || webp;
}

export async function uploadsRoutes(app: FastifyInstance) {
  app.post('/uploads', { onRequest: [app.authenticate] }, async (req, reply) => {
    const file = await req.file();
    if (!file) return reply.code(400).send({ error: 'no_file' });
    const mime = file.mimetype || '';
    if (!ALLOWED_MIME.has(mime)) return reply.code(415).send({ error: 'unsupported_type' });
    const buf = await file.toBuffer();
    if (buf.length === 0) return reply.code(400).send({ error: 'empty_file' });
    if (!isRealImage(buf)) return reply.code(415).send({ error: 'bad_image' });

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
    // Тек рұқсат етілген сурет түрін береміз + браузер мазмұнды «болжамасын» (nosniff).
    const safeMime = ALLOWED_MIME.has(rows[0].mime) ? rows[0].mime : 'application/octet-stream';
    reply.header('Content-Type', safeMime);
    reply.header('X-Content-Type-Options', 'nosniff');
    reply.header('Content-Disposition', 'inline');
    reply.header('Cache-Control', 'public, max-age=31536000, immutable');
    return reply.send(rows[0].data);
  });
}
