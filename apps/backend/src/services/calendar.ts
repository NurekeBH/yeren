import { query } from '../db/client.js';

/// Экономикалық календарь — Forex Factory (faireconomy.media) тегін фиді (кілтсіз).
/// Finnhub-тың economic calendar endpoint-ы premium (403), сондықтан осы көзге көштік.
/// Осы апта + келесі апта оқиғаларын тартып, calendar_events-ке upsert жасайды.

type FFEvent = {
  title: string;
  country: string; // валюта коды (USD, EUR, GBP, ...)
  date: string; // ISO offset-пен: "2026-06-21T21:00:00-04:00"
  impact: string; // Low | Medium | High | Holiday
  forecast?: string;
  previous?: string;
  actual?: string;
};

function mapImpact(i: string): 'low' | 'medium' | 'high' {
  const s = (i || '').toLowerCase();
  if (s.includes('high')) return 'high';
  if (s.includes('medium') || s.includes('moderate')) return 'medium';
  return 'low';
}

const clean = (v?: string): string | null => {
  const t = (v ?? '').trim();
  return t.length > 0 ? t : null;
};

async function fetchFF(url: string): Promise<FFEvent[]> {
  try {
    const res = await fetch(url, {
      headers: { 'User-Agent': 'Mozilla/5.0 (ALTYN)' },
      signal: AbortSignal.timeout(12000),
    });
    if (!res.ok) return [];
    return (await res.json()) as FFEvent[];
  } catch {
    return [];
  }
}

/// Осы апта + келесі апта оқиғаларын тартып, calendar_events-ке upsert.
export async function ingestCalendar(): Promise<{ inserted: number }> {
  const batches = await Promise.all([
    fetchFF('https://nfs.faireconomy.media/ff_calendar_thisweek.json'),
    fetchFF('https://nfs.faireconomy.media/ff_calendar_nextweek.json'),
  ]);
  const events = batches.flat();

  let inserted = 0;
  for (const e of events) {
    if (!e.title || !e.date) continue;
    if ((e.impact || '').toLowerCase().includes('holiday')) continue; // мереке — өткіземіз
    const at = new Date(e.date);
    if (Number.isNaN(at.getTime())) continue;
    const ext = `ff-${e.country}-${e.title}-${e.date}`.slice(0, 250);
    const r = await query<{ inserted: boolean }>(
      `insert into calendar_events (external_id, name, currency, impact, forecast, previous, actual, scheduled_at)
       values ($1,$2,$3,$4,$5,$6,$7,$8)
       on conflict (external_id) do update set
         actual = coalesce(excluded.actual, calendar_events.actual),
         forecast = coalesce(excluded.forecast, calendar_events.forecast),
         previous = coalesce(excluded.previous, calendar_events.previous)
       returning (xmax = 0) as inserted`,
      [ext, e.title, e.country, mapImpact(e.impact), clean(e.forecast), clean(e.previous), clean(e.actual), at.toISOString()],
    );
    if (r.rows.length > 0 && r.rows[0]!.inserted) inserted++;
  }
  return { inserted };
}
