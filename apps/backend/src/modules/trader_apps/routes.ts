import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query, tx } from '../../db/client.js';

/// Расталған трейдер өтінімі: қолданушы жібереді → админ панелінде кезек → approve/reject.
export async function traderAppsRoutes(app: FastifyInstance) {
  // ── Қолданушы өтінім жібереді ──
  app.post('/trader-applications', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = z
      .object({
        years: z.string().max(20).optional(),
        about: z.string().min(10).max(400),
        proof: z.string().max(300).optional(),
      })
      .safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const a = parsed.data;
    // Бұрынғы pending өтінімді ауыстырамыз (бір қолданушыда — бір pending).
    await tx(async (c) => {
      await c.query("delete from trader_applications where user_id = $1 and status = 'pending'", [req.userId]);
      await c.query(
        `insert into trader_applications (user_id, years, about, proof) values ($1,$2,$3,$4)`,
        [req.userId, a.years ?? null, a.about, a.proof ?? null],
      );
    });
    return { ok: true, status: 'pending' };
  });

  // ── Менің өтінімімнің күйі ──
  app.get('/trader-applications/me', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      'select status, created_at, reviewed_at from trader_applications where user_id = $1 order by created_at desc limit 1',
      [req.userId],
    );
    return { application: rows[0] ?? null };
  });

  // ── Админ: кезек (pending) ──
  app.get('/admin/trader-applications', { onRequest: [app.requireAdmin] }, async (req) => {
    const status = ((req.query as { status?: string }).status ?? 'pending').trim();
    const { rows } = await query(
      `select ta.id, ta.user_id, ta.years, ta.about, ta.proof, ta.status, ta.created_at,
              u.name, u.phone
         from trader_applications ta
         join users u on u.id = ta.user_id
        where ta.status = $1
        order by ta.created_at asc
        limit 200`,
      [status],
    );
    return { applications: rows };
  });

  // ── Админ: мақұлдау (қолданушыны расталған трейдер қылады) ──
  app.post('/admin/trader-applications/:id/approve', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const result = await tx(async (c) => {
      const { rows } = await c.query<{ user_id: string }>(
        "update trader_applications set status = 'approved', reviewed_by = $1, reviewed_at = now() where id = $2 and status = 'pending' returning user_id",
        [req.userId, id],
      );
      if (!rows[0]) return null;
      await c.query('update users set is_verified_trader = true where id = $1', [rows[0].user_id]);
      return rows[0];
    });
    if (!result) return reply.code(404).send({ error: 'not_found_or_reviewed' });
    return { ok: true };
  });

  // ── Админ: бас тарту ──
  app.post('/admin/trader-applications/:id/reject', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rowCount } = await query(
      "update trader_applications set status = 'rejected', reviewed_by = $1, reviewed_at = now() where id = $2 and status = 'pending'",
      [req.userId, id],
    );
    if (!rowCount) return reply.code(404).send({ error: 'not_found_or_reviewed' });
    return { ok: true };
  });
}
