import { env } from '../config/env.js';
import { query } from '../db/client.js';
import { sendIntelPush } from './push.js';

/// Әртүрлі көздерден қаржы жаңалықтарын тарту (Finnhub forex/general news).
/// FINNHUB_API_KEY болмаса — no-op (0 қайтарады).
/// Gold-қа әсерін қарапайым эвристикамен жіктейді (кейін Claude-пен ауыстыруға болады).

type FinnhubNews = {
  category: string;
  datetime: number; // unix seconds
  headline: string;
  id: number;
  source: string;
  summary: string;
  url: string;
};

/// Finnhub summary кейде толық HTML (мыс. investinglive мақаласы) қайтарады.
/// UI-да шикі тег көрінбес үшін — таза мәтінге айналдырамыз (блок-тегтер → жол,
/// <li> → •, қалған тегтерді алып тастап, HTML-entity-лерді ашамыз).
export function htmlToText(html: string): string {
  return html
    .replace(/<\s*li[^>]*>/gi, '\n• ')
    .replace(/<\s*(br|\/p|\/li|\/ul|\/ol|\/div|\/h[1-6]|p|h[1-6])[^>]*>/gi, '\n')
    .replace(/<[^>]+>/g, '')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/gi, '&')
    .replace(/&lt;/gi, '<')
    .replace(/&gt;/gi, '>')
    .replace(/&quot;/gi, '"')
    .replace(/&#39;|&apos;|&[lr]squo;/gi, "'")
    .replace(/&[lr]dquo;/gi, '"')
    .replace(/&ndash;/gi, '–')
    .replace(/&mdash;/gi, '—')
    .replace(/&hellip;/gi, '…')
    .replace(/&middot;/gi, '·')
    .replace(/&#x([0-9a-f]+);/gi, (_, h) => String.fromCharCode(parseInt(h, 16)))
    .replace(/&#(\d+);/g, (_, n) => String.fromCharCode(Number(n)))
    .replace(/[ \t]+/g, ' ')
    .replace(/[ \t]*\n[ \t]*/g, '\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

function classifyImpact(text: string): { impact: 'bullish' | 'bearish' | 'neutral'; urgent: boolean } {
  const t = text.toLowerCase();
  const bullish = ['rate cut', 'dovish', 'war', 'sanction', 'tension', 'safe haven', 'inflation rises', 'weak dollar', 'recession'];
  const bearish = ['rate hike', 'hawkish', 'strong dollar', 'dollar rallies', 'yields rise', 'risk-on'];
  const urgentKw = ['breaking', 'war', 'attack', 'sanction', 'emergency', 'fomc', 'rate decision'];
  const isBull = bullish.some((k) => t.includes(k));
  const isBear = bearish.some((k) => t.includes(k));
  const urgent = urgentKw.some((k) => t.includes(k));
  const impact = isBull && !isBear ? 'bullish' : isBear && !isBull ? 'bearish' : 'neutral';
  return { impact, urgent };
}

async function fetchFinnhub(category: string): Promise<FinnhubNews[]> {
  const url = `https://finnhub.io/api/v1/news?category=${category}&token=${env.FINNHUB_API_KEY}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`finnhub_${res.status}`);
  return (await res.json()) as FinnhubNews[];
}

/// Жаңалықтарды тартып, intel_posts-қа жазады (dedup). Жаңа urgent-терге push жібереді.
export async function ingestNews(): Promise<{ inserted: number; sources: string[] }> {
  if (!env.FINNHUB_API_KEY) return { inserted: 0, sources: [] };

  const batches = await Promise.allSettled([fetchFinnhub('forex'), fetchFinnhub('general')]);
  const items: FinnhubNews[] = [];
  for (const b of batches) if (b.status === 'fulfilled') items.push(...b.value);

  let inserted = 0;
  const sources = new Set<string>();
  for (const n of items.slice(0, 60)) {
    const text = htmlToText(n.summary ?? '') || htmlToText(n.headline ?? '');
    if (!text) continue;
    const { impact, urgent } = classifyImpact(`${n.headline} ${n.summary}`);
    sources.add(n.source);
    const { rows } = await query<{ id: string; inserted: boolean }>(
      `insert into intel_posts (source, external_id, text, impact, is_urgent, published_at)
       values ($1, $2, $3, $4, $5, to_timestamp($6))
       on conflict (source, external_id) where external_id is not null
         do update set text = excluded.text, impact = excluded.impact
       returning id, (xmax = 0) as inserted`,
      [n.source, String(n.id), text, impact, urgent, n.datetime],
    );
    // (xmax = 0) → шынымен ЖАҢА жазба. Бар жазба болса — мәтінін жаңартамыз
    // (ескі HTML авто-тазаланады), бірақ қайта санамаймыз әрі push жібермейміз.
    if (rows[0]?.inserted) {
      inserted++;
      if (urgent) await sendIntelPush({ id: rows[0].id, text, impact });
    }
  }
  return { inserted, sources: [...sources] };
}
