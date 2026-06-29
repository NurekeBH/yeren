import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

const ProviderCreate = z.object({
  name: z.string().min(1),
  avatar: z.string().default('📊'),
  bio: z.string().default(''),
  win_rate: z.number().min(0).max(1).default(0),
  avg_rr: z.number().default(0),
  rating: z.number().min(0).max(5).default(0),
  price_per_month: z.number().min(0).default(0),
  trades_count: z.number().int().default(0),
});

/// Провайдерлердің ТІРІ статистикасы — нақты жабылған сигналдардан есептеледі
/// (win_rate/avg_rr/trades_count статикалық емес: сигнал TP/SL-ге жабылғанда жаңарады).
/// closed>0 болса есептелген мән қолданылады, әйтпесе кестедегі мән сақталады.
async function liveProviderStats(): Promise<Record<string, { win_rate: number; avg_rr: number; trades_count: number }>> {
  const { rows } = await query<{ provider_id: string; closed: string; wins: string; avg_rr: string }>(`
    select provider_id,
      count(*) filter (where status <> 'active')::text as closed,
      count(*) filter (where status in ('closed_tp1','closed_tp2','closed_tp3'))::text as wins,
      coalesce(avg(rr) filter (where status <> 'active'), 0)::text as avg_rr
    from signals where provider_id is not null group by provider_id`);
  const map: Record<string, { win_rate: number; avg_rr: number; trades_count: number }> = {};
  for (const r of rows) {
    const closed = Number(r.closed) || 0;
    if (closed > 0) {
      map[r.provider_id] = { win_rate: Number(r.wins) / closed, avg_rr: Number(r.avg_rr), trades_count: closed };
    }
  }
  return map;
}

function applyStats(p: Record<string, unknown>, stat?: { win_rate: number; avg_rr: number; trades_count: number }) {
  return stat ? { ...p, win_rate: stat.win_rate, avg_rr: stat.avg_rr, trades_count: stat.trades_count } : p;
}

export async function providersRoutes(app: FastifyInstance) {
  // Барлық провайдерлер (рейтинг бойынша) — статистика нақты жабылған сигналдардан.
  app.get('/providers', async () => {
    const { rows } = await query<Record<string, unknown>>(
      `select * from signal_providers order by verified desc, rating desc, subscribers desc`,
    );
    const stats = await liveProviderStats();
    return { providers: rows.map((p) => applyStats(p, stats[p.id as string])) };
  });

  app.get('/providers/:id', async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query<Record<string, unknown>>('select * from signal_providers where id = $1', [id]);
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    const stats = await liveProviderStats();
    const ideas = await query('select * from signals where provider_id = $1 order by published_at desc limit 50', [id]);
    return { provider: applyStats(rows[0], stats[id]), ideas: ideas.rows };
  });

  // Пайдаланушының подпискалары
  app.get('/me/subscriptions', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      `select p.* from provider_subscriptions s
         join signal_providers p on p.id = s.provider_id
        where s.user_id = $1`,
      [req.userId],
    );
    return { providers: rows };
  });

  app.post('/providers/:id/subscribe', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const exists = await query('select 1 from signal_providers where id = $1', [id]);
    if (exists.rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    const ins = await query(
      `insert into provider_subscriptions (user_id, provider_id) values ($1, $2)
       on conflict do nothing returning user_id`,
      [req.userId, id],
    );
    // Санақты тек ЖАҢА подписка қосылғанда ғана арттырамыз (қайталанбасын).
    if (ins.rows.length > 0) {
      await query('update signal_providers set subscribers = subscribers + 1 where id = $1', [id]);
    }
    return { ok: true };
  });

  app.delete('/providers/:id/subscribe', { onRequest: [app.authenticate] }, async (req) => {
    const id = (req.params as { id: string }).id;
    const res = await query(
      'delete from provider_subscriptions where user_id = $1 and provider_id = $2',
      [req.userId, id],
    );
    if ((res.rowCount ?? 0) > 0) {
      await query('update signal_providers set subscribers = greatest(0, subscribers - 1) where id = $1', [id]);
    }
    return { ok: true };
  });

  // Admin: провайдер құру / статус беру
  app.post('/providers', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const parsed = ProviderCreate.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const p = parsed.data;
    const { rows } = await query(
      `insert into signal_providers (name, avatar, bio, win_rate, avg_rr, rating, price_per_month, trades_count, verified)
       values ($1,$2,$3,$4,$5,$6,$7,$8,true) returning *`,
      [p.name, p.avatar, p.bio, p.win_rate, p.avg_rr, p.rating, p.price_per_month, p.trades_count],
    );
    return { provider: rows[0] };
  });

  app.patch('/providers/:id/verify', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const verified = z.object({ verified: z.boolean() }).safeParse(req.body);
    if (!verified.success) return reply.code(400).send({ error: 'bad_request' });
    const { rows } = await query(
      'update signal_providers set verified = $1 where id = $2 returning *',
      [verified.data.verified, id],
    );
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    return { provider: rows[0] };
  });
}
