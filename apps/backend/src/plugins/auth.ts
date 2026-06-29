import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import fastifyJwt from '@fastify/jwt';
import { env } from '../config/env.js';
import { query } from '../db/client.js';

declare module 'fastify' {
  interface FastifyInstance {
    authenticate: (req: FastifyRequest, reply: FastifyReply) => Promise<void>;
    requireAdmin: (req: FastifyRequest, reply: FastifyReply) => Promise<void>;
    requireTrader: (req: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
  interface FastifyRequest {
    userId: string;
    isAdmin: boolean;
    jti?: string;
  }
}

declare module '@fastify/jwt' {
  interface FastifyJWT {
    payload: { sub: string; admin?: boolean; jti?: string };
    user: { sub: string; admin?: boolean; jti?: string };
  }
}

export async function registerAuth(app: FastifyInstance) {
  await app.register(fastifyJwt, {
    secret: env.JWT_SECRET,
    sign: { expiresIn: env.JWT_EXPIRES_IN },
  });

  // JWT-ді тексеріп, қолданушыны DB-дан жүктейміз. Токен жарамды болса да
  // қолданушы жоқ болса (мыс. өшірілген) — 401, блокталса — 403. Осылайша
  // ескі/жетім токендер 500 емес, дұрыс жауап қайтарады; админдік DB-дан алынады.
  async function loadUser(
    req: FastifyRequest,
    reply: FastifyReply,
  ): Promise<{ id: string; is_admin: boolean; is_verified_trader: boolean } | null> {
    let decoded: { sub: string; jti?: string };
    try {
      decoded = await req.jwtVerify<{ sub: string; admin?: boolean; jti?: string }>();
    } catch {
      reply.code(401).send({ error: 'unauthorized' });
      return null;
    }
    req.jti = decoded.jti;
    // Сессия ревокациясы: jti бар (жаңа) токендер user_sessions-та белсенді болуы керек.
    // Logout/парольді ауыстыру сессияны жабады. Ескі (jti жоқ) токендер — exp-ке дейін.
    if (decoded.jti) {
      const s = await query('select 1 from user_sessions where jwt_jti = $1 and revoked_at is null', [decoded.jti]);
      if (!s.rowCount) {
        reply.code(401).send({ error: 'session_expired' });
        return null;
      }
    }
    const { rows } = await query<{
      id: string;
      is_admin: boolean;
      is_blocked: boolean;
      is_verified_trader: boolean;
    }>('select id, is_admin, is_blocked, is_verified_trader from users where id = $1', [decoded.sub]);
    const u = rows[0];
    if (!u) {
      reply.code(401).send({ error: 'unauthorized' });
      return null;
    }
    if (u.is_blocked) {
      reply.code(403).send({ error: 'blocked' });
      return null;
    }
    req.userId = u.id;
    req.isAdmin = u.is_admin;
    return u;
  }

  app.decorate('authenticate', async (req: FastifyRequest, reply: FastifyReply) => {
    await loadUser(req, reply);
  });

  app.decorate('requireAdmin', async (req: FastifyRequest, reply: FastifyReply) => {
    const u = await loadUser(req, reply);
    if (!u) return;
    if (!u.is_admin) return reply.code(403).send({ error: 'admin_only' });
  });

  // Админ НЕМЕСЕ расталған трейдер — идея/іс-шара жариялау үшін.
  app.decorate('requireTrader', async (req: FastifyRequest, reply: FastifyReply) => {
    const u = await loadUser(req, reply);
    if (!u) return;
    if (!u.is_admin && !u.is_verified_trader) return reply.code(403).send({ error: 'trader_only' });
  });
}
