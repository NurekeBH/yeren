import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';
import { providerDashboard, adminPayoutsOverview, providerPayoutHistory, type DashPeriod } from './metrics.js';

const PERIODS = new Set(['day', 'week', 'month', 'year', 'all']);

const PayoutBody = z.object({
  user_id: z.string().uuid(),
  amount: z.number().positive(),
  method: z.enum(['card', 'crypto', 'cash']).optional(),
  note: z.string().max(300).optional(),
});

export async function payoutsRoutes(app: FastifyInstance) {
  // ── Дашборд трейдера (его личный кабинет). requireTrader — только верифиц. трейдер. ──
  app.get('/provider/dashboard', { onRequest: [app.requireTrader] }, async (req) => {
    const p = (req.query as { period?: string }).period;
    const period: DashPeriod = (p && PERIODS.has(p) ? p : 'month') as DashPeriod;
    return providerDashboard(req.userId, period);
  });

  // ── Админ: список трейдеров с балансами (раздел выплат). ──
  app.get('/admin/payouts', { onRequest: [app.requireAdmin] }, async () => adminPayoutsOverview());

  // ── Админ: история выплат конкретного трейдера. ──
  app.get('/admin/payouts/:userId', { onRequest: [app.requireAdmin] }, async (req) =>
    providerPayoutHistory((req.params as { userId: string }).userId));

  // ── Админ: зафиксировать выплату трейдеру. ──
  app.post('/admin/payout', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const parsed = PayoutBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;
    // Получатель должен существовать.
    const u = await query('select 1 from users where id = $1', [d.user_id]);
    if (!u.rowCount) return reply.code(404).send({ error: 'not_found' });
    const { rows } = await query<Record<string, unknown>>(
      `insert into provider_payouts (provider_id, user_id, amount, method, note, paid_by)
       values ((select id from signal_providers where user_id = $1), $1, $2, $3, $4, $5)
       returning id, amount, currency, method, note, created_at`,
      [d.user_id, d.amount, d.method ?? null, d.note ?? null, req.userId],
    );
    // Новый суммарный выплачено (для мгновенного обновления баланса в UI).
    const paid = await query<{ paid: string }>(
      'select coalesce(sum(amount),0)::text as paid from provider_payouts where user_id = $1', [d.user_id]);
    return { payout: rows[0], paid: Number(paid.rows[0]?.paid ?? 0) };
  });
}
