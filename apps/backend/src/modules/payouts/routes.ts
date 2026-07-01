import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query, tx } from '../../db/client.js';
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

    // FAIL-SAFE (ACID): всё в одной транзакции. Блокируем строку трейдера (сериализация
    // параллельных выплат → нет двойного списания), проверяем доступный остаток
    // (overdraft-guard), затем пишем лог. Если лог оборвётся — откат, деньги не «утекут».
    const result = await tx(async (c) => {
      await c.query('select 1 from users where id = $1 for update', [d.user_id]);
      const bal = await c.query<{ available: string }>(
        `select
           coalesce((select sum(sp.price_tg) from signals s
                       join signal_purchases sp on sp.signal_id = s.id
                      where s.created_by = $1), 0)
         + coalesce((select sum(cp.bonus_used) from course_catalog cc
                       join course_purchases cp on cp.course_id = cc.id
                      where cc.owner_id = $1), 0)
         - coalesce((select sum(amount) from provider_payouts where user_id = $1), 0) as available`,
        [d.user_id],
      );
      const available = Number(bal.rows[0]?.available ?? 0);
      if (d.amount > available) return { error: 'insufficient_balance' as const, available };
      const ins = await c.query<Record<string, unknown>>(
        `insert into provider_payouts (provider_id, user_id, amount, method, note, paid_by)
         values ((select id from signal_providers where user_id = $1), $1, $2, $3, $4, $5)
         returning id, amount, currency, method, note, created_at`,
        [d.user_id, d.amount, d.method ?? null, d.note ?? null, req.userId],
      );
      return { payout: ins.rows[0], available: available - d.amount };
    });
    if ('error' in result) return reply.code(409).send({ error: result.error, available: result.available });
    return { payout: result.payout, available: result.available };
  });
}
