import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

const SignalCreate = z.object({
  pair: z.string().default('XAU/USD'),
  direction: z.enum(['buy', 'sell']),
  entry_from: z.number(),
  entry_to: z.number(),
  tp1: z.number(),
  tp2: z.number().optional(),
  tp3: z.number().optional(),
  sl: z.number(),
  rr: z.number(),
  confidence: z.number().int().min(0).max(100),
  screenshot_url: z.string().url().optional(),
  analysis: z.string().min(1),
  is_free: z.boolean().default(false),
  provider_id: z.string().uuid().optional(),
  source: z.enum(['admin', 'telegram_bot']).default('admin'),
  source_message_id: z.string().optional(),
});

const SignalClose = z.object({
  status: z.enum(['closed_tp1', 'closed_tp2', 'closed_tp3', 'closed_sl']),
  result_pips: z.number().int(),
});

export async function signalsRoutes(app: FastifyInstance) {
  app.get('/signals', async () => {
    const { rows } = await query(`select * from signals order by published_at desc limit 200`);
    return { signals: rows };
  });

  app.get('/signals/:id', async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query('select * from signals where id = $1', [id]);
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    return { signal: rows[0] };
  });

  // Admin: жариялау (TZ §10.3)
  app.post('/signals', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const parsed = SignalCreate.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const s = parsed.data;
    const { rows } = await query(
      `insert into signals (pair, direction, entry_from, entry_to, tp1, tp2, tp3, sl, rr, confidence,
                            screenshot_url, analysis, is_free, provider_id, source, source_message_id)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
       returning *`,
      [s.pair, s.direction, s.entry_from, s.entry_to, s.tp1, s.tp2 ?? null, s.tp3 ?? null, s.sl, s.rr,
        s.confidence, s.screenshot_url ?? null, s.analysis, s.is_free, s.provider_id ?? null, s.source, s.source_message_id ?? null],
    );
    return { signal: rows[0] };
  });

  // Admin: жабу
  app.post('/signals/:id/close', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = SignalClose.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { rows } = await query(
      `update signals set status = $1, result_pips = $2, closed_at = now() where id = $3 returning *`,
      [parsed.data.status, parsed.data.result_pips, id],
    );
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    return { signal: rows[0] };
  });

  // ─────────────── Ақылы идеялар (TP пипсіне қарай баға) ───────────────
  // Идея бағасы серверде есептеледі (клиентке сенбейміз): XAU/USD pip = 0.10,
  // кіру ортасынан ең алыс TP-ке дейінгі қашықтық 200 пипстен асса — 1000 ₸, әйтпесе 500 ₸.
  const priceFor = (s: {
    entry_from: number; entry_to: number; tp1: number; tp2: number | null; tp3: number | null;
    is_free?: boolean;
  }): number => {
    if (s.is_free) return 0; // тегін идея — paywall жоқ
    const mid = (Number(s.entry_from) + Number(s.entry_to)) / 2;
    const tps = [s.tp1, s.tp2, s.tp3].filter((v) => v != null).map((v) => Number(v));
    const maxDist = tps.reduce((m, tp) => Math.max(m, Math.abs(tp - mid)), 0);
    const pips = maxDist / 0.10;
    return pips > 200 ? 1000 : 500;
  };

  // Пайдаланушы ашқан идеялардың id-тізімі
  app.get('/signals/purchased', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query<{ signal_id: string }>(
      'select signal_id from signal_purchases where user_id = $1',
      [req.userId],
    );
    return { signal_ids: rows.map((r) => r.signal_id) };
  });

  // Идеяны сатып алу (Kaspi төлемінен кейін). Идемпотентті — қайталанса сол баға.
  app.post('/signals/:id/purchase', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query('select * from signals where id = $1', [id]);
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    // Тегін идея — сатып алу қажет емес.
    if (rows[0].is_free) return { ok: true, price_tg: 0, free: true };
    const price = priceFor(rows[0] as never);
    await query(
      `insert into signal_purchases (user_id, signal_id, price_tg)
       values ($1, $2, $3)
       on conflict (user_id, signal_id) do nothing`,
      [req.userId, id, price],
    );
    return { ok: true, price_tg: price };
  });

  // ─────────────── Нәтижеге дауыс беру (ашқан/төлеген қолданушылар) ───────────────
  // Дауыс тек идеяны ашқандарға рұқсат: тегін идея, сатып алған немесе жабылған.
  app.post('/signals/:id/vote', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const body = z.object({ outcome: z.enum(['tp1', 'tp2', 'tp3', 'sl']) }).safeParse(req.body);
    if (!body.success) return reply.code(400).send({ error: 'bad_request' });
    const sig = await query<{ is_free: boolean; status: string }>('select is_free, status from signals where id = $1', [id]);
    if (sig.rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    const s = sig.rows[0]!;
    const purchased = await query('select 1 from signal_purchases where user_id = $1 and signal_id = $2', [req.userId, id]);
    const allowed = s.is_free || s.status !== 'active' || purchased.rows.length > 0;
    if (!allowed) return reply.code(403).send({ error: 'locked' });
    await query(
      `insert into signal_votes (user_id, signal_id, outcome) values ($1,$2,$3)
       on conflict (user_id, signal_id) do update set outcome = excluded.outcome, created_at = now()`,
      [req.userId, id, body.data.outcome],
    );
    return { ok: true };
  });

  // Дауыс қорытындысы (барлық нәтиже бойынша санақ) + пайдаланушының өз дауысы.
  app.get('/signals/:id/votes', { onRequest: [app.authenticate] }, async (req) => {
    const id = (req.params as { id: string }).id;
    const tally = await query<{ outcome: string; n: string }>(
      'select outcome, count(*)::text as n from signal_votes where signal_id = $1 group by outcome',
      [id],
    );
    const mine = await query<{ outcome: string }>(
      'select outcome from signal_votes where signal_id = $1 and user_id = $2',
      [id, req.userId],
    );
    const counts: Record<string, number> = { tp1: 0, tp2: 0, tp3: 0, sl: 0 };
    for (const r of tally.rows) counts[r.outcome] = Number(r.n);
    return { counts, my_vote: mine.rows[0]?.outcome ?? null };
  });

  // ─────────────── Трейдер follow-up апдейттері (timeline) ───────────────
  app.get('/signals/:id/updates', { onRequest: [app.authenticate] }, async (req) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query(
      'select text, created_at from signal_updates where signal_id = $1 order by created_at asc',
      [id],
    );
    return { updates: rows };
  });

  // Апдейт қосу (трейдер/админ).
  app.post('/signals/:id/updates', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = z.object({ text: z.string().min(1).max(500) }).safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { rows } = await query(
      'insert into signal_updates (signal_id, text) values ($1, $2) returning text, created_at',
      [id, parsed.data.text],
    );
    return { ok: true, update: rows[0] };
  });

  // Provider stats (TZ §10.4)
  app.get('/signals/stats', async () => {
    const { rows } = await query<{
      total: string; wins: string; losses: string; sum_win: string; sum_loss: string; avg_rr: string;
    }>(`
      with closed as (
        select * from signals where status <> 'active'
      )
      select
        count(*)::text as total,
        count(*) filter (where status in ('closed_tp1','closed_tp2','closed_tp3'))::text as wins,
        count(*) filter (where status = 'closed_sl')::text as losses,
        coalesce(sum(result_pips) filter (where result_pips > 0), 0)::text as sum_win,
        coalesce(sum(abs(result_pips)) filter (where result_pips < 0), 0)::text as sum_loss,
        coalesce(avg(rr), 0)::text as avg_rr
      from closed
    `);
    const r = rows[0]!;
    const total = Number(r.total) || 0;
    const wins = Number(r.wins) || 0;
    const losses = Number(r.losses) || 0;
    const sumWin = Number(r.sum_win) || 0;
    const sumLoss = Number(r.sum_loss) || 0;
    return {
      total,
      wins,
      losses,
      win_rate: total === 0 ? 0 : wins / total,
      profit_factor: sumLoss === 0 ? null : sumWin / sumLoss,
      avg_rr: Number(r.avg_rr),
    };
  });
}
