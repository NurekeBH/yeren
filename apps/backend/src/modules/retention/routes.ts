import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query, tx } from '../../db/client.js';

// Retention: daily streak (эффект привычки) + удержание при отмене.
const STREAK_REWARD_EVERY = 5; // каждые 5 дней подряд
const STREAK_REWARD = 50; // +50 бонусов

// Оффер удержания по причине отмены (динамический).
const RETENTION_BONUS = 500;
const OfferBody = z.object({
  reason: z.enum(['too_expensive', 'not_useful', 'no_time', 'other']).optional(),
});

export async function retentionRoutes(app: FastifyInstance) {
  // ── Daily streak check-in (вызывается при открытии приложения) ──
  // Идемпотентно за день: last_check == сегодня → без изменений.
  app.post('/streak/checkin', { onRequest: [app.authenticate] }, async (req) => {
    return tx(async (c) => {
      const cur = await c.query<{ streak: number; longest: number; last_check: string | null }>(
        'select streak, longest, last_check from app_streaks where user_id = $1 for update',
        [req.userId],
      );
      const row = cur.rows[0];
      // Дни считаем по UTC-дате сервера (стабильно, без зависимости от TZ телефона).
      const today = new Date().toISOString().slice(0, 10);
      const yesterday = new Date(Date.now() - 86_400_000).toISOString().slice(0, 10);

      let streak = 1;
      if (row) {
        const last = row.last_check ? String(row.last_check).slice(0, 10) : null;
        if (last === today) {
          // Уже заходил сегодня — ничего не меняем и не награждаем повторно.
          return { streak: row.streak, longest: row.longest, awarded: 0, already: true };
        }
        streak = last === yesterday ? row.streak + 1 : 1; // вчера → +1, иначе сброс
      }
      const longest = Math.max(row?.longest ?? 0, streak);

      await c.query(
        `insert into app_streaks (user_id, streak, longest, last_check, updated_at)
         values ($1, $2, $3, $4, now())
         on conflict (user_id) do update set streak = $2, longest = $3, last_check = $4, updated_at = now()`,
        [req.userId, streak, longest, today],
      );

      // Награда за каждые 5 дней подряд.
      let awarded = 0;
      if (streak > 0 && streak % STREAK_REWARD_EVERY === 0) {
        awarded = STREAK_REWARD;
        await c.query('update users set bonus_balance = bonus_balance + $1 where id = $2', [awarded, req.userId]);
        await c.query(
          "insert into bonus_transactions (user_id, type, amount, ref) values ($1,'signup',$2,$3)",
          [req.userId, awarded, `streak:${streak}`],
        );
        // Аналитика: достигнут milestone (для когорт/A-B).
        await c.query(
          `insert into activity_events (user_id, event, entity_type, entity_id, city, country)
           select $1,'streak_milestone_reached','streak',$2,u.city,u.country from users u where u.id=$1`,
          [req.userId, String(streak)],
        );
      }
      return { streak, longest, awarded, already: false };
    });
  });

  // ── Текущий стрейк (для home-счётчика без чек-ина) ──
  app.get('/streak', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query<{ streak: number; longest: number; last_check: string | null }>(
      'select streak, longest, last_check from app_streaks where user_id = $1',
      [req.userId],
    );
    return rows[0] ?? { streak: 0, longest: 0, last_check: null };
  });

  // ── Удержание при отмене: динамический оффер (один раз на пользователя) ──
  // Клиент показывает опрос «почему уходите», по причине предлагает оффер; при
  // принятии — начисляем бонус и фиксируем, чтобы не выдавать повторно.
  app.post('/retention/offer', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = OfferBody.safeParse(req.body ?? {});
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const reason = parsed.data.reason ?? 'other';

    const existing = await query('select 1 from retention_offers where user_id = $1', [req.userId]);
    if (existing.rowCount) return reply.code(409).send({ error: 'already_used' });

    await tx(async (c) => {
      await c.query('update users set bonus_balance = bonus_balance + $1 where id = $2', [RETENTION_BONUS, req.userId]);
      await c.query(
        "insert into bonus_transactions (user_id, type, amount, ref) values ($1,'signup',$2,$3)",
        [req.userId, RETENTION_BONUS, `retention:${reason}`],
      );
      await c.query(
        'insert into retention_offers (user_id, reason, bonus) values ($1, $2, $3)',
        [req.userId, reason, RETENTION_BONUS],
      );
    });
    return { ok: true, bonus: RETENTION_BONUS };
  });
}
