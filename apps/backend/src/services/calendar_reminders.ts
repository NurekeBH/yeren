import { query } from '../db/client.js';
import { sendToCategory } from './push.js';

/// Жоғары әсерлі экономикалық оқиға басталуынан ~15 минут бұрын еске салу push
/// (calendar_on қосулы құрылғыларға). Әр оқиға бір рет (reminder_sent белгісі).
const LEAD_MINUTES = 15;

type EventRow = {
  id: string;
  name: string;
  currency: string;
  scheduled_at: string;
};

export async function sendCalendarReminders(): Promise<{ sent: number }> {
  // Алдағы LEAD_MINUTES ішінде басталатын, әлі ескертілмеген high-impact оқиғалар.
  const { rows } = await query<EventRow>(
    `select id, name, currency, scheduled_at from calendar_events
      where reminder_sent = false
        and impact = 'high'
        and scheduled_at > now()
        and scheduled_at <= now() + ($1 || ' minutes')::interval
      order by scheduled_at asc
      limit 20`,
    [String(LEAD_MINUTES)],
  );

  let sent = 0;
  for (const e of rows) {
    // Қайталанбау үшін алдымен белгілейміз (атомдық: тек false болса).
    const upd = await query(
      'update calendar_events set reminder_sent = true where id = $1 and reminder_sent = false',
      [e.id],
    );
    if (!upd.rowCount) continue;

    const mins = Math.max(1, Math.round((new Date(e.scheduled_at).getTime() - Date.now()) / 60000));
    await sendToCategory('calendar_on', {
      title: `${e.currency} · ${mins} мин`,
      body: e.name,
      data: { type: 'calendar', id: e.id },
    });
    sent += 1;
  }
  return { sent };
}
