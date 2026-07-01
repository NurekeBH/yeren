import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query, tx } from '../../db/client.js';
import { sendToCategory } from '../../services/push.js';

const SignalCreate = z.object({
  pair: z.string().default('XAU/USD'),
  direction: z.enum(['buy', 'sell']),
  entry_from: z.number(),
  entry_to: z.number(),
  tp1: z.number(),
  tp2: z.number().nullish(),
  tp3: z.number().nullish(),
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

/// Сигнал меншігін тексеру: 'ok' (админ немесе автор), 'not_found', 'forbidden'.
/// created_by = null (ескі/админ жариялаған) сигналдарды тек админ басқарады.
async function ownsSignal(
  userId: string,
  isAdmin: boolean,
  signalId: string,
): Promise<'ok' | 'not_found' | 'forbidden'> {
  const { rows } = await query<{ created_by: string | null }>(
    'select created_by from signals where id = $1',
    [signalId],
  );
  if (rows.length === 0) return 'not_found';
  if (isAdmin) return 'ok';
  return rows[0]!.created_by === userId ? 'ok' : 'forbidden';
}

export async function signalsRoutes(app: FastifyInstance) {
  // Токен болса — userId аламыз (is_mine есептеу үшін). Болмаса — аноним.
  const optionalUserId = async (req: { jwtVerify: <T>() => Promise<T> }): Promise<string | null> => {
    try {
      return (await req.jwtVerify<{ sub: string }>()).sub;
    } catch {
      return null;
    }
  };

  app.get('/signals', async (req) => {
    const userId = await optionalUserId(req);
    const { rows } = await query(
      `select s.*, coalesce(s.created_by = $1, false) as is_mine,
              (select count(*)::int from signal_purchases sp where sp.signal_id = s.id) as buyers,
              (select coalesce(jsonb_object_agg(outcome, n), '{}'::jsonb)
                 from (select outcome, count(*)::int as n from signal_votes
                        where signal_id = s.id group by outcome) v) as votes
         from signals s
        where s.deleted_at is null and s.status <> 'expired'
        order by s.published_at desc limit 200`,
      [userId],
    );
    return { signals: rows };
  });

  // ── Менің идеяларым (кірген трейдер жариялаған — белсенді + жабылған) ──
  app.get('/me/signals', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      `select s.*, true as is_mine,
              (select coalesce(jsonb_object_agg(outcome, n), '{}'::jsonb)
                 from (select outcome, count(*)::int as n from signal_votes
                        where signal_id = s.id group by outcome) v) as votes
         from signals s
        where s.created_by = $1 and s.deleted_at is null
        order by s.published_at desc limit 200`,
      [req.userId],
    );
    return { signals: rows };
  });

  // Админ: идеяны (сигналды) ЖҰМСАҚ жою. АНТИ-ФРОД: жазба DB-де қалады (статистика
  // сақталады) — жоғалтқан идеяны өшіріп Win Rate көтеруге болмайды. Тек тізімнен
  // жасырылады. Жабылған (нәтижесі бар) сигнал жойылса да провайдер статистикасында қалады.
  app.delete('/signals/:id', { onRequest: [app.requireAdmin] }, async (req) => {
    await query('update signals set deleted_at = now() where id = $1 and deleted_at is null',
      [(req.params as { id: string }).id]);
    return { ok: true };
  });

  // ── Админ: ЖОЙЫЛҒАН (soft-deleted) сигналдар тізімі — аудит үшін ──
  // Кім, қашан жойды, нәтижесі қандай еді — статистика бұрмалауын бақылау.
  app.get('/admin/signals/deleted', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query(
      `select s.id, s.pair, s.direction, s.status, s.result_pips, s.rr, s.is_free,
              s.published_at, s.closed_at, s.deleted_at, s.created_by, s.provider_id,
              p.name as provider_name, u.name as author_name, u.phone as author_phone
         from signals s
         left join signal_providers p on p.id = s.provider_id
         left join users u on u.id = s.created_by
        where s.deleted_at is not null
        order by s.deleted_at desc limit 200`,
    );
    return { signals: rows };
  });

  // ── Админ: жойылған сигналды қалпына келтіру (қателесіп жойса) ──
  app.post('/admin/signals/:id/restore', { onRequest: [app.requireAdmin] }, async (req) => {
    await query('update signals set deleted_at = null where id = $1',
      [(req.params as { id: string }).id]);
    return { ok: true };
  });

  app.get('/signals/:id', async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const userId = await optionalUserId(req);
    const { rows } = await query(
      'select *, coalesce(created_by = $1, false) as is_mine from signals where id = $2 and deleted_at is null',
      [userId, id],
    );
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    return { signal: rows[0] };
  });

  // Admin: жариялау (TZ §10.3)
  app.post('/signals', { onRequest: [app.requireTrader] }, async (req, reply) => {
    const parsed = SignalCreate.safeParse(req.body);
    if (!parsed.success) {
      const fields = [...new Set(parsed.error.issues.map((i) => i.path.join('.')))].join(', ');
      return reply.code(400).send({ error: 'bad_request', message: `Тексеріңіз: ${fields}`, issues: parsed.error.issues });
    }
    const s = parsed.data;
    // Провайдер (админ емес) сигнал жарияласа — өзінің провайдер профиліне байлаймыз.
    let providerId = s.provider_id ?? null;
    if (!req.isAdmin) {
      const p = await query<{ id: string }>('select id from signal_providers where user_id = $1', [req.userId]);
      if (p.rows[0]) providerId = p.rows[0].id;
    }
    const { rows } = await query(
      `insert into signals (pair, direction, entry_from, entry_to, tp1, tp2, tp3, sl, rr, confidence,
                            screenshot_url, analysis, is_free, provider_id, source, source_message_id, created_by)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)
       returning *`,
      [s.pair, s.direction, s.entry_from, s.entry_to, s.tp1, s.tp2 ?? null, s.tp3 ?? null, s.sl, s.rr,
        s.confidence, s.screenshot_url ?? null, s.analysis, s.is_free, providerId, s.source, s.source_message_id ?? null,
        req.userId],
    );
    const sig = rows[0] as { id: string; pair: string; direction: string; is_free: boolean };
    const dir = sig.direction === 'buy' ? 'BUY' : 'SELL';
    // FREEMIUM HOOK: бесплатный промо-сигнал подаём как супер-ценность (обычно от 500
    // бонусов, сейчас автор открыл БЕСПЛАТНО). Платный — обычный анонс.
    void (async () => {
      let providerName = '';
      if (providerId) {
        const p = await query<{ name: string }>('select name from signal_providers where id = $1', [providerId]);
        providerName = p.rows[0]?.name ?? '';
      }
      const who = providerName ? `Топовый трейдер ${providerName}` : 'Трейдер';
      const data: Record<string, string> = { type: 'signal', id: sig.id };
      if (sig.is_free) data.promo = '1';
      const payload = sig.is_free
        ? {
            title: `🎁 ${who} открыл эксклюзивный сигнал!`,
            body: `${dir} ${sig.pair} по XAUUSD. Обычно от 500 бонусов — сейчас автор дал БЕСПЛАТНЫЙ доступ. Успей!`,
            data,
          }
        : {
            title: `📈 Новый сигнал · ${sig.pair}`,
            body: `${who}: ${dir} ${sig.pair}`,
            data,
          };
      await sendToCategory('signals_on', payload);
    })().catch((err) => req.log.error({ err }, 'push_failed'));
    return { signal: rows[0] };
  });

  // Сигналды жабу — тек жариялаған трейдер (немесе админ).
  app.post('/signals/:id/close', { onRequest: [app.requireTrader] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = SignalClose.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const owns = await ownsSignal(req.userId, req.isAdmin, id);
    if (owns === 'not_found') return reply.code(404).send({ error: 'not_found' });
    if (owns === 'forbidden') return reply.code(403).send({ error: 'not_owner' });
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

    // Бонусты серверде қолданамыз: payable = баға − бонус; баланстан шегереміз.
    // Идемпотентті: бұрын сатып алынса — қайта шегермейміз.
    const result = await tx(async (c) => {
      const existing = await c.query<{ price_tg: number; bonus_used: number }>(
        'select price_tg, bonus_used from signal_purchases where user_id = $1 and signal_id = $2',
        [req.userId, id],
      );
      if (existing.rowCount) {
        return { price_tg: existing.rows[0]!.price_tg, bonus_used: existing.rows[0]!.bonus_used, already: true };
      }
      const u = await c.query<{ bonus_balance: number }>(
        'select bonus_balance from users where id = $1 for update',
        [req.userId],
      );
      const balance = u.rows[0]?.bonus_balance ?? 0;
      const bonusUsed = Math.min(balance, price);
      const payable = price - bonusUsed;
      if (bonusUsed > 0) {
        await c.query('update users set bonus_balance = bonus_balance - $1 where id = $2', [bonusUsed, req.userId]);
        // Бонус леджерге шығыс ретінде жазамыз (монетизация дашборды).
        await c.query(
          "insert into bonus_transactions (user_id, type, amount, ref) values ($1, 'spend_signal', $2, $3)",
          [req.userId, -bonusUsed, `signal:${id}`],
        );
      }
      await c.query(
        'insert into signal_purchases (user_id, signal_id, price_tg, bonus_used) values ($1, $2, $3, $4)',
        [req.userId, id, payable, bonusUsed],
      );
      return { price_tg: payable, bonus_used: bonusUsed, already: false };
    });
    // Аналитика (серверная, надёжная): фиксируем покупку для churn/когорт/A-B.
    if (!result.already) {
      void query(
        `insert into activity_events (user_id, event, entity_type, entity_id, city, country)
         select $1,'signal_purchased','signal',$2,u.city,u.country from users u where u.id=$1`,
        [req.userId, id],
      ).catch(() => {});
    }
    return { ok: true, ...result };
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

  // Апдейт қосу — тек жариялаған трейдер (немесе админ).
  app.post('/signals/:id/updates', { onRequest: [app.requireTrader] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = z.object({ text: z.string().min(1).max(500) }).safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const owns = await ownsSignal(req.userId, req.isAdmin, id);
    if (owns === 'not_found') return reply.code(404).send({ error: 'not_found' });
    if (owns === 'forbidden') return reply.code(403).send({ error: 'not_owner' });
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
        -- Тек TP/SL шешілгендер (active/expired КІРМЕЙДІ). Жойылғандар САНАЛАДЫ (анти-фрод).
        select * from signals where status in ('closed_tp1','closed_tp2','closed_tp3','closed_sl')
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
