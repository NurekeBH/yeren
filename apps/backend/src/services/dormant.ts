import { query } from '../db/client.js';
import { sendToUser } from './push.js';

// RETENTION HOOK: «спящие» пользователи (не заходили 3–30 дней) → персонализированный
// возвратный пуш от топ-трейдера. Троттлинг last_dormant_push_at (не чаще раза в 3 дня).
// Батч на прогон — чтобы не залить FCM разом (на масштабе → очередь, см. DevOps-заметку).
export async function pokeDormantUsers(): Promise<{ pushed: number }> {
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

  // Спящие: last_seen 3–30 дней назад, signals_on, есть токен, не пушили 3 дня. Батч 200.
  const { rows } = await query<{ id: string }>(
    `select u.id from users u
       join notification_prefs np on np.user_id = u.id
      where u.is_blocked = false
        and u.last_seen_at < now() - interval '3 days'
        and u.last_seen_at > now() - interval '30 days'
        and (u.last_dormant_push_at is null or u.last_dormant_push_at < now() - interval '3 days')
        and np.signals_on = true and np.expo_push_token is not null and np.expo_push_token <> ''
      limit 200`,
  );

  let pushed = 0;
  for (const u of rows) {
    await sendToUser(u.id, {
      title: `${name} снова в деле 🔥`,
      body: `Топовый трейдер ${name} публикует сигналы с винрейтом ${wr}%! Успей войти по свежей идее.`,
      data: signalId ? { type: 'signal', id: signalId } : { type: 'signals' },
    }).catch(() => {});
    await query('update users set last_dormant_push_at = now() where id = $1', [u.id]);
    pushed++;
  }
  return { pushed };
}
