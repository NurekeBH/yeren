import type { FastifyInstance, FastifyRequest } from 'fastify';
import { randomUUID } from 'node:crypto';
import bcrypt from 'bcrypt';
import { z } from 'zod';
import { env } from '../../config/env.js';
import { query, tx } from '../../db/client.js';

/// Тұрақты dummy-хэш: белгісіз телефонда да bcrypt.compare-ды орындап, жауап
/// уақытын теңестіреміз (user enumeration-ды timing арқылы болдырмау). Старт кезінде
/// бір рет есептеледі — нақты валидті bcrypt хэш.
const DUMMY_BCRYPT_HASH = bcrypt.hashSync('altyn-timing-equalizer', env.BCRYPT_ROUNDS);

/// Жаңа сессия ашып, токен береді (jti + user_sessions жазбасы → logout/revoke жұмыс істейді).
async function issueToken(
  app: FastifyInstance,
  userId: string,
  isAdmin: boolean,
  req: FastifyRequest,
): Promise<string> {
  const jti = randomUUID();
  // Сессия ~10 жыл (токенмен бірдей) — қолданушы өзі шықпайынша автоматты шықпайды.
  await query(
    `insert into user_sessions (user_id, jwt_jti, user_agent, ip, expires_at)
     values ($1, $2, $3, $4, now() + interval '3650 days')`,
    [userId, jti, String(req.headers['user-agent'] ?? '').slice(0, 200), req.ip ?? null],
  );
  return app.jwt.sign({ sub: userId, admin: isAdmin, jti });
}

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

/** Промокодпен тіркелген ЖАҢА қолданушыға берілетін бонус (ұпай). Маркетинг: реферермен
 *  ТЕҢ — екеуі де 500 алады. */
const PROMO_BONUS_TG = 500;

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
          // Жаңа қолданушыға +500; реферерге +500 және реферал саны +1 (тең).
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
    const token = await issueToken(app, user.id, user.is_admin, req);
    return { token, user_id: user.id };
  });

  // Логин: брутфорстан қорғау (тар rate-limit) + constant-time (timing enumeration жоқ) +
  // блок/жоқ юзер/қате пароль үшін БІРДЕЙ жауап (қай телефон тіркелгенін ашпаймыз).
  app.post('/auth/login', { config: { rateLimit: { max: 8, timeWindow: '1 minute' } } }, async (req, reply) => {
    const parsed = Credentials.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { password } = parsed.data;
    const phone = normalizePhone(parsed.data.phone);

    const { rows } = await query<{ id: string; password_hash: string; is_admin: boolean; is_blocked: boolean }>(
      'select id, password_hash, is_admin, is_blocked from users where phone = $1',
      [phone],
    );
    const user = rows[0];
    // Юзер болмаса да dummy-хэшпен салыстырамыз — жауап уақыты бірдей болады.
    const ok = await bcrypt.compare(password, user?.password_hash ?? DUMMY_BCRYPT_HASH);
    if (!user || !ok || user.is_blocked) {
      return reply.code(401).send({ error: 'invalid_credentials' });
    }

    const token = await issueToken(app, user.id, user.is_admin, req);
    return { token, user_id: user.id };
  });

  // Шығу: ағымдағы сессияны жабамыз (токен бұдан былай жарамсыз).
  app.post('/auth/logout', { onRequest: [app.authenticate] }, async (req) => {
    if (req.jti) {
      await query('update user_sessions set revoked_at = now() where jwt_jti = $1', [req.jti]);
    }
    return { ok: true };
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

  // Профильдің ҚАУІПСІЗ өрістерін ғана өзгертуге рұқсат. РӨЛ (is_verified_trader/is_admin)
  // МҰНДА ЖОҚ — әйтпесе кез келген қолданушы өзін трейдер/админ ете алатын еді (escalation).
  // Рөл тек /admin/users/:id/role + трейдер өтінімін мақұлдау арқылы өзгереді.
  const PROFILE_FIELDS = new Set([
    'name', 'city', 'bio', 'avatar_url', 'trading_styles', 'preferred_sessions', 'locale',
  ]);
  app.patch('/auth/me', { onRequest: [app.authenticate] }, async (req, reply) => {
    const Body = z.object({
      name: z.string().max(60).optional(),
      city: z.string().max(60).optional(),
      bio: z.string().max(200).optional(),
      avatar_url: z.string().url().optional(),
      trading_styles: z.array(z.string()).optional(),
      preferred_sessions: z.array(z.string()).optional(),
      locale: z.enum(['kk', 'ru', 'en']).optional(),
      // promo_code/is_verified_trader/is_admin клиенттен ҚАБЫЛДАНБАЙДЫ.
    });
    const parsed = Body.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });

    const set: string[] = [];
    const args: unknown[] = [];
    for (const [k, v] of Object.entries(parsed.data)) {
      if (v === undefined || !PROFILE_FIELDS.has(k)) continue; // тек whitelist өрістер
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

  /// Бонусты толтыру (Kaspi төлемі РАСТАЛҒАННАН кейін).
  /// ҚАУІПСІЗДІК: бұрын кез келген қолданушы өзіне шексіз баланс «басып шығара» алатын
  /// еді (төлем тексерілмейтін). Енді тек АДМИН (немесе сервер вебхугы) расталған
  /// төлем бойынша есептейді + payment_id арқылы идемпотент (бір төлем — бір рет).
  /// TODO: нақты Kaspi вебхугын қосып, ол подписьті тексеріп осы логиканы шақырсын.
  app.post('/bonus/topup', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const Body = z.object({
      user_id: z.string().uuid(),
      amount: z.number().int().min(1).max(1_000_000),
      payment_id: z.string().min(6).max(120),
    });
    const parsed = Body.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { user_id, amount, payment_id } = parsed.data;
    const ref = `kaspi:${payment_id}`;
    try {
      const balance = await tx(async (c) => {
        const dup = await c.query('select 1 from bonus_transactions where ref = $1', [ref]);
        if (dup.rowCount) throw new Error('duplicate');
        const r = await c.query<{ bonus_balance: number }>(
          'update users set bonus_balance = bonus_balance + $1 where id = $2 returning bonus_balance',
          [amount, user_id],
        );
        if (!r.rowCount) throw new Error('no_user');
        await c.query(
          "insert into bonus_transactions (user_id, type, amount, ref) values ($1, 'topup', $2, $3)",
          [user_id, amount, ref],
        );
        return r.rows[0]!.bonus_balance;
      });
      return { ok: true, bonus_balance: balance };
    } catch (e) {
      const msg = e instanceof Error ? e.message : '';
      if (msg === 'duplicate') return reply.code(409).send({ error: 'already_processed' });
      if (msg === 'no_user') return reply.code(404).send({ error: 'not_found' });
      throw e;
    }
  });
}
