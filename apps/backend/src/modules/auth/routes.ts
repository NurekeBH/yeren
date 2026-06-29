import type { FastifyInstance } from 'fastify';
import bcrypt from 'bcrypt';
import { z } from 'zod';
import { env } from '../../config/env.js';
import { query, tx } from '../../db/client.js';

const Credentials = z.object({
  phone: z.string().min(7).max(20),
  password: z.string().min(8).max(64),
});

const RegisterBody = Credentials.extend({
  name: z.string().min(1).max(60).optional(),
  city: z.string().max(60).optional(),
  country: z.string().length(2).optional(), // ISO-2 (тіркеуде таңдалған ел коды) — тіл шешімі үшін
  trading_styles: z.array(z.string()).optional(),
  preferred_sessions: z.array(z.string()).optional(),
  locale: z.enum(['kk', 'ru', 'en']).optional(),
  promo_code: z.string().max(24).optional(),
});

/**
 * Телефонды E.164-ке келтіру (болашақ WhatsApp верификациясына дайындық).
 * Бос орын/тире/жақша алынады; 00 префиксі → +; Қазақстан/Ресей 8XXXXXXXXXX → +7XXXXXXXXXX;
 * 11 цифрлы 7… → +7…; алдыңғы + кепілдендіріледі. Тіркеу де, кіру де бірдей форматты қолданады.
 */
export function normalizePhone(raw: string): string {
  let p = raw.replace(/[\s\-()]/g, '');
  if (p.startsWith('00')) p = `+${p.slice(2)}`;
  if (/^8\d{10}$/.test(p)) p = `+7${p.slice(1)}`;
  else if (/^7\d{10}$/.test(p)) p = `+${p}`;
  else if (!p.startsWith('+') && /^\d{10,15}$/.test(p)) p = `+${p}`;
  return p;
}

/** Промокодпен тіркелген ЖАҢА қолданушыға берілетін бонус (ұпай). */
const PROMO_BONUS_TG = 100;

/** Промокодын бөліскен реферерге әр тіркелу үшін бонус (ұпай). */
const REFERRER_BONUS_TG = 500;

/** Шатастырмайтын таңбалар (O/0/I/1 жоқ). */
const PROMO_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

function randomPromoCode(len = 6): string {
  let s = '';
  for (let i = 0; i < len; i++) {
    s += PROMO_ALPHABET[Math.floor(Math.random() * PROMO_ALPHABET.length)];
  }
  return s;
}

type Runner = (sql: string, params?: unknown[]) => Promise<{ rowCount: number | null }>;

/// Бірегей промокод генерациялау (DB-да тексеру + қайталау). Unique constraint —
/// соңғы кепіл; бұл цикл коллизия ықтималдығын нөлге жақындатады.
async function genUniquePromoCode(run: Runner): Promise<string> {
  for (let i = 0; i < 8; i++) {
    const code = randomPromoCode();
    const { rowCount } = await run('select 1 from users where promo_code = $1', [code]);
    if (!rowCount) return code;
  }
  return randomPromoCode(8); // өте сирек — ұзынырақ код
}

/**
 * TZ.rtf override: SMS жоқ. Тек phone + password (bcrypt).
 */
export async function authRoutes(app: FastifyInstance) {
  app.post('/auth/register', async (req, reply) => {
    const parsed = RegisterBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const { password, name, city, country, trading_styles, preferred_sessions, locale, promo_code } = parsed.data;
    const phone = normalizePhone(parsed.data.phone);

    const exists = await query('select 1 from users where phone = $1', [phone]);
    if (exists.rowCount && exists.rowCount > 0) {
      return reply.code(409).send({ error: 'phone_already_registered' });
    }

    const hash = await bcrypt.hash(password, env.BCRYPT_ROUNDS);

    const { rows } = await tx(async (c) => {
      // Сервер бірегей промокод генерациялайды (клиентке сенбейміз — қайталанбау кепілі).
      const ownPromo = await genUniquePromoCode((sql, p) => c.query(sql, p as never[]));
      const u = await c.query<{ id: string; is_admin: boolean }>(
        `insert into users (phone, password_hash, name, city, country, trading_styles, preferred_sessions, locale, promo_code)
         values ($1,$2,$3,$4,$5,$6,$7,$8,$9)
         returning id, is_admin`,
        [phone, hash, name ?? '', city ?? '', (country ?? '').toUpperCase(), trading_styles ?? [], preferred_sessions ?? [], locale ?? 'kk', ownPromo],
      );
      await c.query(
        `insert into notification_prefs (user_id) values ($1) on conflict do nothing`,
        [u.rows[0]!.id],
      );
      await c.query(
        `insert into user_progress (user_id) values ($1) on conflict do nothing`,
        [u.rows[0]!.id],
      );
      await c.query(
        `insert into subscriptions (user_id, status) values ($1, 'inactive')`,
        [u.rows[0]!.id],
      );
      // Промокодпен тіркелсе — жаңа қолданушыға бонус, трейдерге +1 реферал.
      const code = promo_code?.trim().toUpperCase();
      if (code) {
        const ref = await c.query<{ id: string }>(
          'select id from users where upper(promo_code) = $1 limit 1',
          [code],
        );
        if (ref.rowCount && ref.rows[0]!.id !== u.rows[0]!.id) {
          // Жаңа қолданушыға +100; реферерге +500 және реферал саны +1.
          await c.query('update users set bonus_balance = $1, referred_by = $2 where id = $3', [
            PROMO_BONUS_TG,
            code,
            u.rows[0]!.id,
          ]);
          await c.query(
            'update users set bonus_balance = bonus_balance + $1, referral_count = referral_count + 1 where id = $2',
            [REFERRER_BONUS_TG, ref.rows[0]!.id],
          );
        }
      }
      return u;
    });

    const user = rows[0]!;
    const token = app.jwt.sign({ sub: user.id, admin: user.is_admin });
    return { token, user_id: user.id };
  });

  app.post('/auth/login', async (req, reply) => {
    const parsed = Credentials.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { password } = parsed.data;
    const phone = normalizePhone(parsed.data.phone);

    const { rows } = await query<{ id: string; password_hash: string; is_admin: boolean; is_blocked: boolean }>(
      'select id, password_hash, is_admin, is_blocked from users where phone = $1',
      [phone],
    );
    const user = rows[0];
    if (!user) return reply.code(401).send({ error: 'invalid_credentials' });
    if (user.is_blocked) return reply.code(403).send({ error: 'account_blocked' });

    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return reply.code(401).send({ error: 'invalid_credentials' });

    const token = app.jwt.sign({ sub: user.id, admin: user.is_admin });
    return { token, user_id: user.id };
  });

  app.get('/auth/me', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query<Record<string, unknown>>(
      `select id, phone, name, city, bio, avatar_url, trading_styles, preferred_sessions, locale, is_admin,
              is_verified_trader, promo_code, referred_by, bonus_balance, referral_count, created_at
       from users where id = $1`,
      [req.userId],
    );
    const user = rows[0];
    // Ескі қолданушыларда промокод болмаса — бірегейін генерациялап сақтаймыз (backfill).
    if (user && !user.promo_code) {
      const code = await genUniquePromoCode(query);
      await query('update users set promo_code = $1 where id = $2', [code, req.userId]);
      user.promo_code = code;
    }
    return { user };
  });

  app.patch('/auth/me', { onRequest: [app.authenticate] }, async (req, reply) => {
    const Body = z.object({
      name: z.string().max(60).optional(),
      city: z.string().max(60).optional(),
      bio: z.string().max(200).optional(),
      avatar_url: z.string().url().optional(),
      trading_styles: z.array(z.string()).optional(),
      preferred_sessions: z.array(z.string()).optional(),
      locale: z.enum(['kk', 'ru', 'en']).optional(),
      is_verified_trader: z.boolean().optional(),
      // promo_code клиенттен ҚАБЫЛДАНБАЙДЫ — оны сервер генерациялайды (бірегейлік кепілі).
    });
    const parsed = Body.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });

    const set: string[] = [];
    const args: unknown[] = [];
    for (const [k, v] of Object.entries(parsed.data)) {
      if (v === undefined) continue;
      args.push(v);
      set.push(`${k} = $${args.length}`);
    }
    if (set.length === 0) return { ok: true };
    args.push(req.userId);
    await query(`update users set ${set.join(', ')} where id = $${args.length}`, args);
    return { ok: true };
  });

  // Аккаунтты толық жою (Apple App Store 5.1.1(v) талабы — қосымшаішілік жою).
  // Байланысты деректер FK on delete cascade арқылы өшеді; қалғаны set null.
  app.delete('/auth/me', { onRequest: [app.authenticate] }, async (req) => {
    await query('delete from users where id = $1', [req.userId]);
    return { ok: true };
  });

  /**
   * Тіркелуден кейін промокод қолдану. Бір рет қана бонус беріледі.
   */
  app.post('/promo/redeem', { onRequest: [app.authenticate] }, async (req, reply) => {
    const Body = z.object({ code: z.string().min(4).max(24) });
    const parsed = Body.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const code = parsed.data.code.trim().toUpperCase();

    const me = await query<{ referred_by: string | null; promo_code: string | null }>(
      'select referred_by, promo_code from users where id = $1',
      [req.userId],
    );
    const u = me.rows[0];
    if (!u) return reply.code(404).send({ error: 'not_found' });
    if (u.referred_by) return reply.code(409).send({ error: 'already_used' });
    if (u.promo_code && u.promo_code.toUpperCase() === code) {
      return reply.code(400).send({ error: 'own_code' });
    }

    const ref = await query<{ id: string }>(
      'select id from users where upper(promo_code) = $1 limit 1',
      [code],
    );
    if (!ref.rowCount || ref.rows[0]!.id === req.userId) {
      return reply.code(404).send({ error: 'invalid_code' });
    }

    await tx(async (c) => {
      await c.query('update users set bonus_balance = bonus_balance + $1, referred_by = $2 where id = $3', [
        PROMO_BONUS_TG,
        code,
        req.userId,
      ]);
      // Реферерге +500 және реферал саны +1.
      await c.query(
        'update users set bonus_balance = bonus_balance + $1, referral_count = referral_count + 1 where id = $2',
        [REFERRER_BONUS_TG, ref.rows[0]!.id],
      );
      // Бонус леджерге жазамыз (монетизация дашборды үшін).
      await c.query(
        "insert into bonus_transactions (user_id, type, amount, ref) values ($1, 'referral', $2, $3)",
        [req.userId, PROMO_BONUS_TG, `promo:${code}`],
      );
      await c.query(
        "insert into bonus_transactions (user_id, type, amount, ref) values ($1, 'referral', $2, $3)",
        [ref.rows[0]!.id, REFERRER_BONUS_TG, `invite:${req.userId}`],
      );
    });
    return { ok: true, bonus: PROMO_BONUS_TG };
  });

  /// Бонусты толтыру (Kaspi төлемі расталғаннан кейін). Балансқа қосамыз.
  app.post('/bonus/topup', { onRequest: [app.authenticate] }, async (req, reply) => {
    const Body = z.object({ amount: z.number().int().min(1).max(100000) });
    const parsed = Body.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const amount = parsed.data.amount;
    const balance = await tx(async (c) => {
      const r = await c.query<{ bonus_balance: number }>(
        'update users set bonus_balance = bonus_balance + $1 where id = $2 returning bonus_balance',
        [amount, req.userId],
      );
      // Топ-ап = Kaspi кірісі (1 бонус = 1 ₸). Монетизация дашбордына жазамыз.
      await c.query(
        "insert into bonus_transactions (user_id, type, amount, ref) values ($1, 'topup', $2, 'kaspi')",
        [req.userId, amount],
      );
      return r.rows[0]?.bonus_balance ?? 0;
    });
    return { ok: true, bonus_balance: balance };
  });
}
