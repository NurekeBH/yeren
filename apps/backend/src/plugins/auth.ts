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
  }
}

declare module '@fastify/jwt' {
  interface FastifyJWT {
    payload: { sub: string; admin?: boolean };
    user: { sub: string; admin?: boolean };
  }
}

export async function registerAuth(app: FastifyInstance) {
  await app.register(fastifyJwt, {
    secret: env.JWT_SECRET,
    sign: { expiresIn: env.JWT_EXPIRES_IN },
  });

  app.decorate('authenticate', async (req: FastifyRequest, reply: FastifyReply) => {
    try {
      const decoded = await req.jwtVerify<{ sub: string; admin?: boolean }>();
      req.userId = decoded.sub;
      req.isAdmin = !!decoded.admin;
    } catch {
      return reply.code(401).send({ error: 'unauthorized' });
    }
  });

  app.decorate('requireAdmin', async (req: FastifyRequest, reply: FastifyReply) => {
    try {
      const decoded = await req.jwtVerify<{ sub: string; admin?: boolean }>();
      req.userId = decoded.sub;
      req.isAdmin = !!decoded.admin;
      if (!decoded.admin) return reply.code(403).send({ error: 'admin_only' });
    } catch {
      return reply.code(401).send({ error: 'unauthorized' });
    }
  });

  // Админ НЕМЕСЕ расталған трейдер — идея/іс-шара жариялау үшін.
  app.decorate('requireTrader', async (req: FastifyRequest, reply: FastifyReply) => {
    try {
      const decoded = await req.jwtVerify<{ sub: string; admin?: boolean }>();
      req.userId = decoded.sub;
      req.isAdmin = !!decoded.admin;
      if (decoded.admin) return;
      const { rows } = await query<{ is_verified_trader: boolean }>(
        'select is_verified_trader from users where id = $1',
        [decoded.sub],
      );
      if (!rows[0]?.is_verified_trader) return reply.code(403).send({ error: 'trader_only' });
    } catch {
      return reply.code(401).send({ error: 'unauthorized' });
    }
  });
}
