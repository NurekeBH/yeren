import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';
import { ingestNews } from '../../services/news.js';
import { sendIntelPush } from '../../services/push.js';

const IntelCreate = z.object({
  source: z.string().min(1),
  external_id: z.string().optional(),
  text: z.string().min(1),
  impact: z.enum(['bullish', 'bearish', 'neutral']),
  xau_move: z.number().optional(),
  analysis: z.string().optional(),
  support: z.number().optional(),
  resistance: z.number().optional(),
  suggested_sl: z.number().optional(),
  sentiment: z.number().int().min(0).max(100).optional(),
  is_urgent: z.boolean().optional(),
  published_at: z.string().datetime().optional(),
});

export async function intelRoutes(app: FastifyInstance) {
  app.get('/intel', async (req) => {
    const Q = z.object({ limit: z.coerce.number().int().min(1).max(100).default(30) });
    const { limit } = Q.parse(req.query);
    const { rows } = await query(
      `select * from intel_posts order by published_at desc limit $1`,
      [limit],
    );
    return { posts: rows };
  });

  // Admin/ingest: жаңалық қосу (RSS poller / Trump X scraper шақырады)
  app.post('/intel', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const parsed = IntelCreate.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;
    try {
      const { rows } = await query(
        `insert into intel_posts (source, external_id, text, impact, xau_move, analysis, support,
                                  resistance, suggested_sl, sentiment, is_urgent, published_at)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,coalesce($11,false),coalesce($12, now()))
         on conflict (source, external_id) where external_id is not null
         do update set text = excluded.text, analysis = excluded.analysis
         returning *`,
        [d.source, d.external_id ?? null, d.text, d.impact, d.xau_move ?? null, d.analysis ?? null,
          d.support ?? null, d.resistance ?? null, d.suggested_sl ?? null, d.sentiment ?? null,
          d.is_urgent ?? false, d.published_at ?? null],
      );
      const post = rows[0] as { id: string; text: string; impact: string; is_urgent: boolean };
      if (post.is_urgent) {
        void sendIntelPush({ id: post.id, text: post.text, impact: post.impact });
      }
      return { post };
    } catch (err) {
      app.log.error(err);
      return reply.code(500).send({ error: 'insert_failed' });
    }
  });

  // Admin: әртүрлі көздерден жаңалықтарды тарту (Finnhub forex/general).
  // FINNHUB_API_KEY керек. Cron/worker немесе админ қолмен шақыра алады.
  app.post('/intel/ingest', { onRequest: [app.requireAdmin] }, async () => {
    const result = await ingestNews();
    return { ok: true, ...result };
  });
}
