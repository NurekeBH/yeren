import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

// Пайдаланушы келісімін қабылдау логы (заңды талап).
export async function agreementRoutes(app: FastifyInstance) {
  app.post('/agreement/accept', { onRequest: [app.authenticate] }, async (req) => {
    const version = z.object({ version: z.string().default('v1') }).safeParse(req.body);
    const v = version.success ? version.data.version : 'v1';
    const ua = req.headers['user-agent'] ?? null;
    const { rows } = await query(
      `insert into agreement_acceptances (user_id, version, ip, user_agent)
       values ($1, $2, $3, $4) returning id, version, accepted_at`,
      [req.userId, v, req.ip, ua],
    );
    return { acceptance: rows[0] };
  });

  app.get('/agreement/me', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      'select version, accepted_at from agreement_acceptances where user_id = $1 order by accepted_at desc limit 1',
      [req.userId],
    );
    return { accepted: rows.length > 0, latest: rows[0] ?? null };
  });
}
