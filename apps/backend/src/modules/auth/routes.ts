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
  trading_styles: z.array(z.string()).optional(),
  preferred_sessions: z.array(z.string()).optional(),
  locale: z.enum(['kk', 'ru', 'en']).optional(),
});

/**
 * TZ.rtf override: SMS жоқ. Тек phone + password (bcrypt).
 */
export async function authRoutes(app: FastifyInstance) {
  app.post('/auth/register', async (req, reply) => {
    const parsed = RegisterBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const { phone, password, name, city, trading_styles, preferred_sessions, locale } = parsed.data;

    const exists = await query('select 1 from users where phone = $1', [phone]);
    if (exists.rowCount && exists.rowCount > 0) {
      return reply.code(409).send({ error: 'phone_already_registered' });
    }

    const hash = await bcrypt.hash(password, env.BCRYPT_ROUNDS);

    const { rows } = await tx(async (c) => {
      const u = await c.query<{ id: string; is_admin: boolean }>(
        `insert into users (phone, password_hash, name, city, trading_styles, preferred_sessions, locale)
         values ($1,$2,$3,$4,$5,$6,$7)
         returning id, is_admin`,
        [phone, hash, name ?? '', city ?? '', trading_styles ?? [], preferred_sessions ?? [], locale ?? 'kk'],
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
      return u;
    });

    const user = rows[0]!;
    const token = app.jwt.sign({ sub: user.id, admin: user.is_admin });
    return { token, user_id: user.id };
  });

  app.post('/auth/login', async (req, reply) => {
    const parsed = Credentials.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { phone, password } = parsed.data;

    const { rows } = await query<{ id: string; password_hash: string; is_admin: boolean }>(
      'select id, password_hash, is_admin from users where phone = $1',
      [phone],
    );
    const user = rows[0];
    if (!user) return reply.code(401).send({ error: 'invalid_credentials' });

    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return reply.code(401).send({ error: 'invalid_credentials' });

    const token = app.jwt.sign({ sub: user.id, admin: user.is_admin });
    return { token, user_id: user.id };
  });

  app.get('/auth/me', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      `select id, phone, name, city, bio, avatar_url, trading_styles, preferred_sessions, locale, is_admin, created_at
       from users where id = $1`,
      [req.userId],
    );
    return { user: rows[0] };
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
}
