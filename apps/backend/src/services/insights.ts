// AI Marketing Insights: детерминированные SQL-детекторы находят аномалию (триггер),
// Claude формулирует совет (копирайтер). Работает И БЕЗ ключа Claude — тогда берётся
// детерминированный текст. Запускается планировщиком (server.ts) раз в час.
import type { FastifyBaseLogger } from 'fastify';
import { query } from '../db/client.js';
import { finance, engagement } from '../modules/bi/metrics.js';
import { claudeText } from './anthropic.js';

type Severity = 'critical' | 'warning' | 'opportunity' | 'info';
type Raw = {
  detector: string;
  key: string; // дедуп-ключ внутри детектора
  severity: Severity;
  title: string;
  facts: string; // для Claude
  body: string; // детерминированный фолбэк
  action: string;
  action_kind: string;
  meta: Record<string, unknown>;
};

const num = (v: unknown): number => Number(v ?? 0);
const tg = (v: number): string => `${Math.round(v).toLocaleString('ru-RU')} ₸`;

// ── Детектор 1: гео-всплеск спроса на курс ──
async function detectGeoSpike(): Promise<Raw[]> {
  const { rows } = await query<Record<string, string>>(`
    with cur as (
      select u.city, cp.course_id, count(*) c
        from course_purchases cp join users u on u.id = cp.user_id
       where cp.created_at >= now() - interval '7 days' and coalesce(u.city,'') <> ''
       group by u.city, cp.course_id
    ), prev as (
      select u.city, cp.course_id, count(*) c
        from course_purchases cp join users u on u.id = cp.user_id
       where cp.created_at >= now() - interval '14 days' and cp.created_at < now() - interval '7 days'
         and coalesce(u.city,'') <> ''
       group by u.city, cp.course_id
    )
    select cur.city, cur.course_id, cur.c cur_c, coalesce(prev.c,0) prev_c,
           coalesce(cc.title->>'ru', cc.title->>'kk', cur.course_id) title
      from cur
      left join prev on prev.city = cur.city and prev.course_id = cur.course_id
      left join course_catalog cc on cc.id = cur.course_id
     where cur.c >= 3
     order by cur.c desc limit 8
  `);
  const out: Raw[] = [];
  for (const r of rows) {
    const cur = num(r.cur_c);
    const prev = num(r.prev_c);
    if (!(prev === 0 || cur / prev >= 1.5)) continue;
    const delta = prev === 0 ? 100 : Math.round((cur / prev - 1) * 100);
    out.push({
      detector: 'geo_spike',
      key: `${r.city}:${r.course_id}`,
      severity: 'opportunity',
      title: `${r.city} разогрелся: курс «${r.title}»`,
      facts: `Город ${r.city}: покупок курса «${r.title}» за 7 дней ${cur} (рост +${delta}% к прошлой неделе).`,
      body: `За неделю покупки курса «${r.title}» в городе ${r.city} выросли на ${delta}% (${cur} покупок). Сейчас лучший момент усилить спрос.`,
      action: `Push на сегмент «город = ${r.city}» с акцией на курс + пригласить локального провайдера`,
      action_kind: 'push_segment',
      meta: { key: `${r.city}:${r.course_id}`, city: r.city, course_id: r.course_id, delta_pct: delta },
    });
  }
  return out;
}

// ── Детектор 2: отток подписчиков у провайдера ──
async function detectProviderChurn(): Promise<Raw[]> {
  const { rows } = await query<Record<string, string>>(`
    select p.id, p.name, p.subscribers,
           count(*) filter (where e.action='unsubscribe' and e.created_at >= now()-interval '30 days') lost
      from signal_providers p
      left join provider_subscription_events e on e.provider_id = p.id
     group by p.id
    having p.subscribers >= 10
       and count(*) filter (where e.action='unsubscribe' and e.created_at >= now()-interval '30 days')::float
           / nullif(p.subscribers,0) > 0.15
     order by lost desc limit 5
  `);
  return rows.map((r) => {
    const lost = num(r.lost);
    const subs = num(r.subscribers);
    const lostPct = Math.round((lost / Math.max(subs, 1)) * 100);
    return {
      detector: 'provider_churn',
      key: r.id,
      severity: 'warning' as Severity,
      title: `Отток у провайдера ${r.name}`,
      facts: `Провайдер ${r.name}: за 30 дней отписалось ${lost} из ${subs} подписчиков (${lostPct}%).`,
      body: `Провайдер ${r.name} потерял ${lostPct}% аудитории за месяц (${lost} отписок). Стоит разобрать качество идей или поддержать его в ленте.`,
      action: 'Проверить качество идей провайдера / временно поднять в топ ленты',
      action_kind: 'promote_provider',
      meta: { key: r.id, provider_id: r.id, lost, lost_pct: lostPct },
    };
  });
}

// ── Детектор 3: LTV/CAC ниже здорового порога ──
async function detectLtvCac(): Promise<Raw[]> {
  const f = await finance();
  if (f.cac <= 0 || f.new_paying_30d === 0) return []; // нет данных по расходу/платящим
  if (f.ltv_cac >= 3) return [];
  const critical = f.ltv_cac < 1;
  return [{
    detector: 'ltv_cac',
    key: 'global',
    severity: critical ? 'critical' : 'warning',
    title: `LTV/CAC = ${f.ltv_cac}× ${critical ? '(убыточно!)' : '(ниже нормы)'}`,
    facts: `LTV платящего ${tg(f.ltv_total)}, CAC ${tg(f.cac)}, соотношение ${f.ltv_cac}× (норма > 3). Новых платящих за 30д: ${f.new_paying_30d}.`,
    body: `Привлечение дороже отдачи: LTV/CAC = ${f.ltv_cac}× при норме > 3 (LTV ${tg(f.ltv_total)}, CAC ${tg(f.cac)}). ${critical ? 'Бизнес теряет деньги на привлечении.' : 'Маржинальность под давлением.'}`,
    action: 'Снизить бюджет худшего по CAC канала / усилить удержание и допродажи',
    action_kind: 'none',
    meta: { key: 'global', ltv_cac: f.ltv_cac, cac: f.cac, ltv: f.ltv_total },
  }];
}

// ── Детектор 4: «горячий» сегмент (открыли paywall, но не купили) ──
async function detectHotSegment(): Promise<Raw[]> {
  const { rows } = await query<Record<string, string>>(`
    select count(distinct a.user_id) n
      from activity_events a
     where a.event='open_paywall' and a.created_at >= now()-interval '3 days'
       and not exists (select 1 from signal_purchases sp where sp.user_id=a.user_id and sp.created_at >= a.created_at)
       and not exists (select 1 from course_purchases cp where cp.user_id=a.user_id and cp.created_at >= a.created_at)
  `);
  const n = num(rows[0]?.n);
  if (n < 5) return [];
  return [{
    detector: 'hot_segment',
    key: 'paywall_no_buy',
    severity: 'opportunity',
    title: `${n} пользователей у кассы без покупки`,
    facts: `${n} пользователей за 3 дня открыли платный контент (paywall), но не купили.`,
    body: `${n} пользователей за 3 дня дошли до оплаты, но не купили — высокий интент. Точечная добивка часто конвертирует таких лучше всего.`,
    action: 'Push «вам не хватает N бонусов» + бонус-добивка на этот сегмент',
    action_kind: 'push_segment',
    meta: { key: 'paywall_no_buy', count: n },
  }];
}

// ── Детектор 5: «тихий» город (много юзеров, ноль покупок) ──
async function detectSilentCity(): Promise<Raw[]> {
  const { rows } = await query<Record<string, string>>(`
    select u.city, count(*) users
      from users u
     where coalesce(u.city,'') <> ''
     group by u.city
    having count(*) >= 50
       and not exists (
         select 1 from course_purchases cp join users u2 on u2.id=cp.user_id
          where u2.city = u.city and cp.created_at >= now()-interval '30 days')
     order by users desc limit 5
  `);
  return rows.map((r) => ({
    detector: 'silent_city',
    key: r.city,
    severity: 'opportunity' as Severity,
    title: `${r.city}: аудитория есть, продаж нет`,
    facts: `В городе ${r.city} ${num(r.users)} пользователей, но 0 покупок курсов за 30 дней.`,
    body: `В ${r.city} уже ${num(r.users)} пользователей, но за месяц — ни одной покупки курса. Спящий спрос, который можно разбудить.`,
    action: `Локальный вебинар/ивент в ${r.city} или таргет-акция на этот город`,
    action_kind: 'promo',
    meta: { key: r.city, city: r.city, users: num(r.users) },
  }));
}

// ── Детектор 6: спад вовлечённости (низкий stickiness) ──
async function detectStickiness(): Promise<Raw[]> {
  const e = await engagement();
  if (e.mau < 50 || e.stickiness_pct >= 10) return [];
  return [{
    detector: 'stickiness',
    key: 'low',
    severity: 'warning',
    title: `Низкий Stickiness: ${e.stickiness_pct}%`,
    facts: `DAU ${e.dau}, MAU ${e.mau}, Stickiness ${e.stickiness_pct}% (норма зрелого продукта 20%+).`,
    body: `Залипаемость ${e.stickiness_pct}% при норме 20%+ — пользователи заходят редко. Нужна реактивация (streak-напоминания, ценные пуши).`,
    action: 'Активационная push-кампания / напоминания о streak в Академии',
    action_kind: 'push_segment',
    meta: { key: 'low', dau: e.dau, mau: e.mau, stickiness: e.stickiness_pct },
  }];
}

const DETECTORS = [
  detectGeoSpike, detectProviderChurn, detectLtvCac,
  detectHotSegment, detectSilentCity, detectStickiness,
];

const SYSTEM = 'Ты — маркетинговый аналитик финтех-приложения ALTYN (трейдинг золота XAU/USD, ' +
  'аудитория Казахстан и СНГ). Пиши кратко и по-деловому, на русском. Максимум 2 предложения. ' +
  'Без markdown, без воды, без приветствий — только суть инсайта для администратора.';

/** Прогон всех детекторов → дедуп → Claude-копирайтинг → запись в admin_insights. */
export async function generateInsights(log?: FastifyBaseLogger): Promise<{ created: number }> {
  let raws: Raw[] = [];
  for (const d of DETECTORS) {
    try {
      raws = raws.concat(await d());
    } catch (err) {
      log?.warn({ err, detector: d.name }, 'insight_detector_failed');
    }
  }
  let created = 0;
  for (const r of raws.slice(0, 12)) {
    // Дедуп: тот же детектор+ключ за последние 20 часов — не плодим карточки.
    const dup = await query(
      `select 1 from admin_insights
        where detector = $1 and meta->>'key' = $2 and created_at > now() - interval '20 hours' limit 1`,
      [r.detector, r.key],
    );
    if (dup.rowCount) continue;
    // Claude формулирует тело (если ключ есть); иначе — детерминированный текст.
    const body = (await claudeText(`Факты: ${r.facts}\nПредложенное действие: ${r.action}\nСформулируй тело уведомления (без заголовка).`, { system: SYSTEM, maxTokens: 200 })) ?? r.body;
    await query(
      `insert into admin_insights (detector, severity, title, body, action, action_kind, meta)
       values ($1,$2,$3,$4,$5,$6,$7::jsonb)`,
      [r.detector, r.severity, r.title, body, r.action, r.action_kind, JSON.stringify(r.meta)],
    );
    created++;
  }
  if (created > 0) log?.info({ created }, 'insights_generated');
  return { created };
}
