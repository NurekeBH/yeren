import type { FastifyInstance } from 'fastify';
import { env } from '../../config/env.js';

/// Сурет жүктеу: multipart файлды Supabase Storage-қа салып, public URL қайтарады.
/// SUPABASE_URL/SUPABASE_SERVICE_KEY болмаса 503 — клиент жергілікті жолға қайтады.
/// «uploads» бакеті Supabase-те public болуы керек (бір рет қолмен жасалады).
const BUCKET = 'uploads';

export async function uploadsRoutes(app: FastifyInstance) {
  app.post('/uploads', { onRequest: [app.authenticate] }, async (req, reply) => {
    if (!env.SUPABASE_URL || !env.SUPABASE_SERVICE_KEY) {
      return reply.code(503).send({ error: 'storage_not_configured' });
    }

    const file = await req.file();
    if (!file) return reply.code(400).send({ error: 'no_file' });

    const buf = await file.toBuffer();
    const rawExt = (file.filename?.split('.').pop() ?? 'jpg').toLowerCase();
    const ext = /^[a-z0-9]{1,5}$/.test(rawExt) ? rawExt : 'jpg';
    // Уникалды жол: user/timestamp-random.ext (Date.now backend-те қолжетімді).
    const path = `${req.userId}/${Date.now()}-${Math.random().toString(36).slice(2, 8)}.${ext}`;

    const res = await fetch(`${env.SUPABASE_URL}/storage/v1/object/${BUCKET}/${path}`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.SUPABASE_SERVICE_KEY}`,
        'Content-Type': file.mimetype || 'application/octet-stream',
        'x-upsert': 'true',
      },
      body: buf,
    });

    if (!res.ok) {
      const detail = await res.text().catch(() => '');
      app.log.error({ status: res.status, detail }, 'supabase upload failed');
      return reply.code(502).send({ error: 'upload_failed' });
    }

    return { url: `${env.SUPABASE_URL}/storage/v1/object/public/${BUCKET}/${path}` };
  });
}
