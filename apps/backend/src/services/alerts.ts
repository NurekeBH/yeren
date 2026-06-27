import { query } from '../db/client.js';
import { getXauPrice } from './prices.js';
import { sendToUser } from './push.js';

/// Баға дабылдарын тексеру: тірі баға мақсатты деңгейді КИГЕНДЕ push жіберіп,
/// дабылды өшіреміз (бір рет атылады). Қиылысты анықтау үшін алдыңғы бағаны сақтаймыз.

let _lastPrice: number | null = null;

type AlertRow = {
  id: string;
  user_id: string;
  instrument: string;
  target_price: string; // numeric → string
  text: string;
};

export async function checkPriceAlerts(): Promise<{ triggered: number; price: number | null }> {
  const price = getXauPrice(); // ортақ кэш (price poller жаңартып отырады) — дисплеймен бір дереккөз
  if (price == null) return { triggered: 0, price: null };

  const prev = _lastPrice;
  _lastPrice = price;
  if (prev == null) return { triggered: 0, price }; // алғашқы поллда тек baseline

  const { rows } = await query<AlertRow>(
    'select id, user_id, instrument, target_price, text from price_alerts where active = true',
  );

  let triggered = 0;
  for (const a of rows) {
    const target = Number(a.target_price);
    if (!Number.isFinite(target)) continue;
    // Қиылыс: алдыңғы баға мен қазіргі баға мақсаттың әртүрлі жағында болса
    // (немесе дәл тиген болса) — дабыл атылады.
    const crossedUp = prev < target && price >= target;
    const crossedDown = prev > target && price <= target;
    if (!crossedUp && !crossedDown) continue;

    await query('update price_alerts set active = false, triggered_at = now() where id = $1 and active = true', [a.id]);
    await sendToUser(a.user_id, {
      title: `${a.instrument} ${target.toFixed(2)}`,
      body: a.text,
      data: { type: 'price_alert', id: a.id, price: price.toFixed(2) },
    });
    triggered += 1;
  }
  return { triggered, price };
}
