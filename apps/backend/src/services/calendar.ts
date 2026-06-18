import { env } from '../config/env.js';
import { query } from '../db/client.js';

/// Finnhub экономикалық календарынан live деректер тарту (trusted көз).
/// FINNHUB_API_KEY болмаса немесе endpoint қолжетімсіз (premium/403) болса — no-op.

type FinnhubCal = {
  country: string;
  event: string;
  impact: string;
  actual: number | null;
  estimate: number | null;
  prev: number | null;
  time: string; // "YYYY-MM-DD HH:MM:SS" (UTC)
  unit?: string;
};

// Ел коды → валюта (календарьде валюта чипі көрсетіледі).
const CCY: Record<string, string> = {
  US: 'USD', EU: 'EUR', DE: 'EUR', FR: 'EUR', IT: 'EUR', ES: 'EUR',
  GB: 'GBP', JP: 'JPY', CN: 'CNY', CA: 'CAD', AU: 'AUD', NZ: 'NZD',
  CH: 'CHF', KZ: 'KZT', RU: 'RUB', IN: 'INR',
};

function mapImpact(i: string): 'low' | 'medium' | 'high' {
  const s = (i || '').toString().toLowerCase();
  if (s.includes('high') || s === '3') return 'high';
  if (s.includes('medium') || s.includes('moderate') || s === '2') return 'medium';
  return 'low';
}

function isoUtc(t: string): string | null {
  // Finnhub: "2024-01-01 12:30:00" (UTC) → ISO.
  if (!t) return null;
  const norm = t.includes('T') ? t : t.replace(' ', 'T');
  const d = new Date(norm.endsWith('Z') ? norm : `${norm}Z`);
  return Number.isNaN(d.getTime()) ? null : d.toISOString();
}

/// Алдағы 2 аптаның экономикалық оқиғаларын тартып, calendar_events-ке upsert жасайды.
export async function ingestCalendar(): Promise<{ inserted: number }> {
  if (!env.FINNHUB_API_KEY) return { inserted: 0 };
  const now = new Date();
  const to = new Date(now.getTime() + 14 * 86400000);
  const fmt = (d: Date) => d.toISOString().slice(0, 10);
  const url = `https://finnhub.io/api/v1/calendar/economic?from=${fmt(now)}&to=${fmt(to)}&token=${env.FINNHUB_API_KEY}`;

  let rows: FinnhubCal[] = [];
  try {
    const res = await fetch(url);
    if (!res.ok) return { inserted: 0 }; // premium/403/429 — тыныш өткіземіз
    const data = (await res.json()) as { economicCalendar?: FinnhubCal[] };
    rows = data.economicCalendar ?? [];
  } catch {
    return { inserted: 0 };
  }

  let inserted = 0;
  for (const e of rows) {
    const at = isoUtc(e.time);
    if (!e.event || !at) continue;
    const ccy = CCY[e.country] ?? e.country;
    const ext = `fh-${e.country}-${e.event}-${e.time}`.slice(0, 250);
    const r = await query<{ inserted: boolean }>(
      `insert into calendar_events (external_id, name, currency, impact, forecast, previous, actual, scheduled_at)
       values ($1,$2,$3,$4,$5,$6,$7,$8)
       on conflict (external_id) do update set
         actual = coalesce(excluded.actual, calendar_events.actual),
         forecast = coalesce(excluded.forecast, calendar_events.forecast),
         previous = coalesce(excluded.previous, calendar_events.previous)
       returning (xmax = 0) as inserted`,
      [ext, e.event, ccy, mapImpact(e.impact),
        e.estimate?.toString() ?? null, e.prev?.toString() ?? null, e.actual?.toString() ?? null, at],
    );
    if (r.rows.length > 0 && r.rows[0]!.inserted) inserted++;
  }
  return { inserted };
}
