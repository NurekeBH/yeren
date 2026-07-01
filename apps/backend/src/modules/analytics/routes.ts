import type { FastifyInstance, FastifyRequest } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

// Medallion Bronze: приём сырых событий из Flutter (append-only, «как есть»).
const EventBody = z.object({
  event_id: z.string().max(64).optional(),        // клиентский UUID (дедуп в Silver)
  event: z.string().min(1).max(60),
  payload: z.record(z.unknown()).optional(),
  device: z.string().max(20).optional(),          // android | ios | web
  app_version: z.string().max(20).optional(),
  client_ts: z.string().optional(),
});

// Опциональный user_id (событие может быть анонимным до логина).
async function optionalUserId(req: FastifyRequest): Promise<string | null> {
  try {
    const d = await req.jwtVerify<{ sub: string }>();
    return d.sub ?? null;
  } catch {
    return null;
  }
}

export async function analyticsRoutes(app: FastifyInstance) {
  // Приём одного события или батча {events:[...]} (батч — экономия сети на клиенте).
  app.post('/analytics/event', { config: { rateLimit: { max: 120, timeWindow: '1 minute' } } }, async (req, reply) => {
    const userId = await optionalUserId(req);
    const raw = req.body as { events?: unknown[] } | unknown;
    const list = Array.isArray((raw as { events?: unknown[] })?.events)
      ? (raw as { events: unknown[] }).events
      : [raw];
    const events = list
      .map((e) => EventBody.safeParse(e))
      .filter((p): p is z.SafeParseSuccess<z.infer<typeof EventBody>> => p.success)
      .map((p) => p.data)
      .slice(0, 100); // защита от флуда

    if (events.length === 0) return reply.code(400).send({ error: 'bad_request' });

    // Bulk insert (один запрос) — append-only, без трансформации.
    const cols: string[] = [];
    const args: unknown[] = [];
    events.forEach((e, i) => {
      const o = i * 7;
      cols.push(`($${o + 1},$${o + 2},$${o + 3}::jsonb,$${o + 4},$${o + 5},$${o + 6},$${o + 7})`);
      const clientTs = e.client_ts && !Number.isNaN(Date.parse(e.client_ts)) ? e.client_ts : null;
      args.push(e.event_id ?? null, e.event, JSON.stringify(e.payload ?? {}), userId, e.device ?? null, e.app_version ?? null, clientTs);
    });
    await query(
      `insert into bronze_events (event_id, event, payload, _user_id, _source_device, _app_version, _client_ts)
       values ${cols.join(',')}`,
      args,
    );
    return { ok: true, ingested: events.length };
  });

  // Админ: чтение Gold-витрин (для дашборда/BI).
  app.get('/admin/analytics/gold', { onRequest: [app.requireAdmin] }, async () => {
    const [funnel, traders, cohorts] = await Promise.all([
      query('select * from gold_growth_funnel order by date desc limit 90'),
      query('select * from gold_trader_performance order by total_bonus_earned desc limit 50'),
      query('select * from gold_retention_cohorts order by cohort_date desc limit 90'),
    ]);
    return { funnel: funnel.rows, traders: traders.rows, cohorts: cohorts.rows };
  });
}
