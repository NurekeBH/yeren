import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

// Deferred deep link рефералы (self-hosted fingerprint, без сторонних SDK).
// Поток: лендинг /invite фиксирует клик → приложение при первом запуске резолвит по IP.
const CODE_RE = /^[A-Z0-9]{4,24}$/;
const ClickBody = z.object({ code: z.string().min(4).max(24) });

export async function inviteRoutes(app: FastifyInstance) {
  // ── Лендинг фиксирует клик по реферальной ссылке (публично, rate-limit) ──
  app.post('/invite/click', { config: { rateLimit: { max: 30, timeWindow: '1 minute' } } }, async (req, reply) => {
    const parsed = ClickBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const code = parsed.data.code.trim().toUpperCase();
    if (!CODE_RE.test(code)) return reply.code(400).send({ error: 'bad_request' });
    const ua = (req.headers['user-agent'] ?? '').toString().slice(0, 300);
    // req.ip = реальный клиентский IP (trustProxy 'loopback' → X-Forwarded-For от nginx).
    await query('insert into referral_clicks (code, ip, user_agent) values ($1, $2, $3)', [code, req.ip, ua]);
    return { ok: true };
  });

  // ── Приложение при ПЕРВОМ запуске: по IP находит недавний неиспользованный клик ──
  // Матч по IP в окне 60 мин + код должен существовать. consumed_at → повторно не выдаётся.
  app.post('/invite/resolve', { config: { rateLimit: { max: 20, timeWindow: '1 minute' } } }, async (req) => {
    const { rows } = await query<{ id: string; code: string }>(
      `select rc.id, rc.code
         from referral_clicks rc
        where rc.ip = $1 and rc.consumed_at is null
          and rc.created_at > now() - interval '60 minutes'
          and exists (select 1 from users u where upper(u.promo_code) = rc.code)
        order by rc.created_at desc limit 1`,
      [req.ip],
    );
    const hit = rows[0];
    if (!hit) return { code: null };
    // Помечаем использованным — один клик не может засеять несколько инсталлов.
    await query('update referral_clicks set consumed_at = now() where id = $1', [hit.id]);
    return { code: hit.code };
  });
}
