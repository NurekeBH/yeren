import { query } from '../db/client.js';

// Детектор шэринга аккаунта — БЕЗ авто-разлогина (бессрочная сессия — бизнес-правило).
// Считает distinct IP аккаунта за окно; при превышении порога ставит ФЛАГ + инсайт
// админу (лента /admin/bi/insights). Решение о бане — ручное.
const WINDOW_MIN = 15;      // окно наблюдения
const IP_THRESHOLD = 3;     // 3+ разных IP за 15 мин → подозрение (2 = wifi↔cellular, норм)

export async function detectAccountSharing(): Promise<{ flagged: number }> {
  // Пользователи с 3+ разными IP за окно.
  const { rows } = await query<{ user_id: string; ips: string; phone: string | null }>(
    `select h.user_id, count(distinct h.ip)::text as ips, u.phone
       from session_ip_hits h
       join users u on u.id = h.user_id
      where h.seen_at > now() - interval '${WINDOW_MIN} minutes'
      group by h.user_id, u.phone
     having count(distinct h.ip) >= ${IP_THRESHOLD}
      limit 100`,
  );

  let flagged = 0;
  for (const r of rows) {
    // Дедуп: не плодим инсайт по одному юзеру чаще раза в 24ч.
    const dup = await query(
      `select 1 from admin_insights
        where detector = 'account_sharing' and meta->>'key' = $1
          and created_at > now() - interval '24 hours' limit 1`,
      [r.user_id],
    );
    if (dup.rowCount) continue;

    const masked = r.phone ? r.phone.replace(/.(?=.{4})/g, '•') : r.user_id.slice(0, 8);
    await query('update users set sharing_flagged_at = now() where id = $1', [r.user_id]);
    await query(
      `insert into admin_insights (detector, severity, title, body, action, action_kind, meta)
       values ('account_sharing','warning',$1,$2,$3,'none',$4::jsonb)`,
      [
        `Возможный шэринг аккаунта: ${masked}`,
        `Аккаунт ${masked} за ${WINDOW_MIN} мин использовался с ${r.ips} разных IP — вероятно, доступ передан нескольким людям (слив платных сигналов).`,
        'Проверить активность и при подтверждении — заблокировать аккаунт вручную',
        JSON.stringify({ key: r.user_id, user_id: r.user_id, distinct_ips: Number(r.ips) }),
      ],
    );
    flagged++;
  }

  // Чистим старые хиты (> 1 дня) — таблица не растёт бесконечно.
  await query("delete from session_ip_hits where seen_at < now() - interval '1 day'").catch(() => {});
  return { flagged };
}
