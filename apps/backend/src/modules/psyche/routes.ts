import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';

// Behavioral Nudge Engine: психо-предпочтения + анти-тильт состояние.
const TILT_COOLDOWN_HOURS = 2;

const PrefsBody = z.object({
  frequency: z.enum(['every', 'summary']).optional(),
  style: z.enum(['direct', 'gamified']).optional(),
  focus_hours: z.boolean().optional(),
  tz_offset_min: z.number().int().min(-720).max(840).optional(),
});

export async function psycheRoutes(app: FastifyInstance) {
  // ── Получить предпочтения (создаём дефолт при первом обращении) ──
  app.get('/me/psyche', { onRequest: [app.authenticate] }, async (req) => {
    await query('insert into user_psyche_preferences (user_id) values ($1) on conflict do nothing', [req.userId]);
    const { rows } = await query(
      'select frequency, style, focus_hours, tz_offset_min from user_psyche_preferences where user_id = $1',
      [req.userId],
    );
    return rows[0] ?? { frequency: 'every', style: 'direct', focus_hours: true, tz_offset_min: 300 };
  });

  // ── Обновить предпочтения (онбординг «как тебе комфортно» / настройки) ──
  app.put('/me/psyche', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = PrefsBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const d = parsed.data;
    const set: string[] = [];
    const args: unknown[] = [req.userId];
    for (const [k, v] of Object.entries(d)) {
      if (v === undefined) continue;
      args.push(v);
      set.push(`${k} = $${args.length}`);
    }
    // Upsert: гарантируем строку, затем применяем изменения.
    await query('insert into user_psyche_preferences (user_id) values ($1) on conflict do nothing', [req.userId]);
    if (set.length > 0) {
      set.push('updated_at = now()');
      await query(`update user_psyche_preferences set ${set.join(', ')} where user_id = $1`, args);
    }
    return { ok: true };
  });

  // ── Анти-тильт: 2 закрытых сделки подряд в минус → пауза 2ч ──
  // Источник — journal_trades.profit (реальные сделки MT). Кулдаун хранится в user_states.
  app.get('/me/tilt', { onRequest: [app.authenticate] }, async (req) => {
    // Уже в кулдауне?
    const st = await query<{ tilt_until: string | null }>(
      'select tilt_until from user_states where user_id = $1',
      [req.userId],
    );
    const until = st.rows[0]?.tilt_until ? new Date(st.rows[0].tilt_until) : null;
    if (until && until.getTime() > Date.now()) {
      return { tilt: true, until: until.toISOString(), losing_streak: 2 };
    }

    // Последние 2 закрытые сделки — обе в минус?
    const { rows } = await query<{ profit: string }>(
      `select profit from journal_trades
        where user_id = $1 and closed_at is not null
        order by closed_at desc limit 2`,
      [req.userId],
    );
    const losses = rows.filter((r) => Number(r.profit) < 0).length;
    const tilt = rows.length >= 2 && losses === 2;

    if (tilt) {
      const cooldown = new Date(Date.now() + TILT_COOLDOWN_HOURS * 3_600_000);
      await query(
        `insert into user_states (user_id, state, tilt_until, updated_at)
         values ($1, 'tilt', $2, now())
         on conflict (user_id) do update set state = 'tilt', tilt_until = $2, updated_at = now()`,
        [req.userId, cooldown.toISOString()],
      );
      return { tilt: true, until: cooldown.toISOString(), losing_streak: 2 };
    }

    // Не в тильте — сбрасываем состояние.
    await query(
      `insert into user_states (user_id, state, tilt_until, updated_at)
       values ($1, 'active', null, now())
       on conflict (user_id) do update set state = 'active', tilt_until = null, updated_at = now()`,
      [req.userId],
    );
    return { tilt: false, until: null, losing_streak: losses };
  });
}
