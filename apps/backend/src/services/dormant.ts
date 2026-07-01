import { query } from '../db/client.js';
import { sendToUser } from './push.js';
import { buildNudge, type NudgeStyle } from './nudge.js';

// RETENTION HOOK: «спящие» пользователи (не заходили 3–30 дней) → персонализированный
// возвратный пуш от топ-трейдера. Троттлинг last_dormant_push_at (не чаще раза в 3 дня).
// Батч на прогон — чтобы не залить FCM разом (на масштабе → очередь, см. DevOps-заметку).
export async function pokeDormantUsers(): Promise<{ pushed: number; skipped?: string }> {
  // Рынок XAU/USD не работает в выходные → не будим (пуш о «новом сигнале» бессмыслен
  // и раздражает). В понедельник догоняем всех, кто был неактивен с пятницы — рынок открыт.
  const day = new Date().getUTCDay(); // 0=вс, 6=сб
  if (day === 0 || day === 6) return { pushed: 0, skipped: 'weekend' };

  // Топовый верифицированный провайдер — для персонализации («трейдер X, винрейт Y%»).
  const topRow = await query<{ name: string; win_rate: string }>(
    `select name, win_rate from signal_providers where verified = true order by win_rate desc nulls last limit 1`,
  );
  const top = topRow.rows[0];
  const name = top?.name ?? 'наш топ-трейдер';
  const wr = top ? Math.round(Number(top.win_rate) * 100) : 80;

  // Свежий активный сигнал за 3 дня — deep link ведёт прямо на него (рост DAU).
  const fresh = await query<{ id: string }>(
    `select id from signals
      where deleted_at is null and status = 'active' and published_at > now() - interval '3 days'
      order by published_at desc limit 1`,
  );
  const signalId = fresh.rows[0]?.id;

  // Спящие: неактивны 18ч–30д (порог поднят с 3д до 18ч, временно), signals_on, есть
  // токен, не пушили 3 дня. FOCUS HOURS: только если у юзера сейчас НЕ тихие часы
  // (22:00–08:00 по его tz_offset_min). Стиль пуша — по психо-предпочтениям. Батч 200.
  const { rows } = await query<{ id: string; style: string }>(
    `select u.id, coalesce(pp.style, 'direct') as style
       from users u
       join notification_prefs np on np.user_id = u.id
       left join user_psyche_preferences pp on pp.user_id = u.id
      where u.is_blocked = false
        and u.last_seen_at < now() - interval '18 hours'
        and u.last_seen_at > now() - interval '30 days'
        and (u.last_dormant_push_at is null or u.last_dormant_push_at < now() - interval '3 days')
        and np.signals_on = true and np.expo_push_token is not null and np.expo_push_token <> ''
        and (coalesce(pp.focus_hours, true) = false
             or extract(hour from (now() + make_interval(mins => coalesce(pp.tz_offset_min, 300)))) between 8 and 21)
      limit 200`,
  );

  let pushed = 0;
  for (const u of rows) {
    const nudge = buildNudge(u.style as NudgeStyle, { trader: name, winRate: wr });
    await sendToUser(u.id, {
      ...nudge,
      data: signalId ? { type: 'signal', id: signalId } : { type: 'signals' },
    }).catch(() => {});
    await query('update users set last_dormant_push_at = now() where id = $1', [u.id]);
    pushed++;
  }
  return { pushed };
}
