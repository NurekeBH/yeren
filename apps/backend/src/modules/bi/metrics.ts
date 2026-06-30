// BI метрики (Growth + CFO). Чистые функции: SQL → нормализованный объект.
// Денежная модель ALTYN: бонус = внутренняя валюта (1:1 ₸). РЕАЛЬНЫЕ деньги входят
// только через bonus_transactions(type='topup', Kaspi→бонус) и subscriptions (Kaspi).
// Курсы/идеи списывают бонус — это оборот, НЕ новый доход. Выданные signup/referral
// бонусы — маркетинг-расход (CAC).
import { query } from '../../db/client.js';

const num = (v: unknown): number => Number(v ?? 0);
const pct = (a: number, b: number): number => (b > 0 ? Math.round((a / b) * 1000) / 10 : 0);

// ── Engagement: DAU / WAU / MAU / Stickiness ──
// Источник — users.last_seen_at (heartbeat в authenticate). Работает сразу после
// деплоя бэкенда, не дожидаясь мобильного трекинга.
export async function engagement() {
  const { rows } = await query<Record<string, string>>(`
    select
      count(*) filter (where last_seen_at >= date_trunc('day', now()))      as dau,
      count(*) filter (where last_seen_at >= now() - interval '7 days')      as wau,
      count(*) filter (where last_seen_at >= now() - interval '30 days')     as mau,
      count(*) filter (where last_seen_at >= date_trunc('day', now()) - interval '1 day'
                         and last_seen_at <  date_trunc('day', now()))       as dau_yesterday
    from users
  `);
  const r = rows[0] ?? {};
  const dau = num(r.dau);
  const mau = num(r.mau);
  return {
    dau,
    wau: num(r.wau),
    mau,
    dau_yesterday: num(r.dau_yesterday),
    stickiness_pct: pct(dau, mau), // норма зрелого продукта 20%+
  };
}

// ── CFO: MRR / ARR / Churn / LTV / CAC / Net Profit ──
export async function finance() {
  const [mrrRow, netRow, churnRow, ltvRow, cacRow, weeklyRows] = await Promise.all([
    // MRR / ARR / активные подписки
    query<Record<string, string>>(`
      select coalesce(sum(amount),0) as mrr, count(*) as active_subs,
             coalesce(round(avg(amount)),0) as arpa
        from subscriptions
       where status = 'active' and (expires_at is null or expires_at > now())
    `),
    // Доход и расход за 30 дней (для Net Profit / маржи)
    query<Record<string, string>>(`
      select
        (select coalesce(sum(amount),0) from bonus_transactions
          where type='topup' and created_at >= now() - interval '30 days')                       as topup_30d,
        (select coalesce(sum(amount),0) from subscriptions
          where activated_at >= now() - interval '30 days')                                       as sub_30d,
        (select coalesce(sum(amount_kzt),0) from marketing_spend
          where spent_on >= now() - interval '30 days')                                           as ext_spend_30d,
        (select coalesce(sum(amount),0) from bonus_transactions
          where type in ('signup','referral') and created_at >= now() - interval '30 days')       as bonus_spend_30d
    `),
    // Churn подписок: был активен 30 дней назад, не активен сейчас
    query<Record<string, string>>(`
      with active_prev as (
        select distinct user_id from subscriptions
         where activated_at < now() - interval '30 days'
           and (expires_at is null or expires_at >= now() - interval '30 days')
      ), active_now as (
        select distinct user_id from subscriptions
         where status='active' and (expires_at is null or expires_at > now())
      )
      select (select count(*) from active_prev) as base,
             (select count(*) from active_prev p
               where not exists (select 1 from active_now n where n.user_id = p.user_id)) as churned
    `),
    // LTV: реальные деньги на платящего (подписки + топапы), без корр. подзапросов
    query<Record<string, string>>(`
      with sub as (select user_id, sum(amount) v from subscriptions
                    where status in ('active','expired') group by user_id),
           top as (select user_id, sum(amount) v from bonus_transactions
                    where type='topup' group by user_id),
           rev as (
             select u.id, coalesce(sub.v,0) sub_rev, coalesce(top.v,0) topup_rev
               from users u
               left join sub on sub.user_id = u.id
               left join top on top.user_id = u.id
           )
      select count(*) filter (where sub_rev+topup_rev > 0)                                  as paying_users,
             coalesce(round(avg(sub_rev)   filter (where sub_rev+topup_rev > 0)),0)         as ltv_sub,
             coalesce(round(avg(topup_rev) filter (where sub_rev+topup_rev > 0)),0)         as ltv_topup,
             coalesce(round(avg(sub_rev+topup_rev) filter (where sub_rev+topup_rev > 0)),0) as ltv_total
        from rev
    `),
    // CAC: (внешний расход + реферальные выплаты ₸) / новые платящие за 30 дней
    query<Record<string, string>>(`
      with spend as (select coalesce(sum(amount_kzt),0) ext from marketing_spend
                       where spent_on >= now() - interval '30 days'),
           ref as (select coalesce(sum(amount),0) ref_kzt from bonus_transactions
                     where type in ('referral','signup') and created_at >= now() - interval '30 days'),
           firstpay as (
             select user_id, min(created_at) fp from (
               select user_id, created_at from subscriptions where status in ('active','expired')
               union all
               select user_id, created_at from bonus_transactions where type='topup'
             ) p group by user_id
           ),
           newpay as (select count(*) n from firstpay where fp >= now() - interval '30 days')
      select spend.ext, ref.ref_kzt, newpay.n as new_paying,
             (spend.ext + ref.ref_kzt) as cost,
             case when newpay.n > 0 then round((spend.ext + ref.ref_kzt)/newpay.n) else 0 end as cac
        from spend, ref, newpay
    `),
    // Недельный ряд (8 недель): выручка vs маркетинг — для Line/Bar графиков
    query<Record<string, string>>(`
      with weeks as (
        select generate_series(date_trunc('week', now()) - interval '7 weeks',
                               date_trunc('week', now()), interval '1 week') as wk
      ),
      rev as (select date_trunc('week', created_at) wk, sum(amount) v from bonus_transactions
                where type='topup' and created_at >= now()-interval '8 weeks' group by 1),
      sub as (select date_trunc('week', coalesce(activated_at, created_at)) wk, sum(amount) v from subscriptions
                where coalesce(activated_at, created_at) >= now()-interval '8 weeks' group by 1),
      mext as (select date_trunc('week', spent_on::timestamptz) wk, sum(amount_kzt) v from marketing_spend
                where spent_on >= now()-interval '8 weeks' group by 1),
      mbon as (select date_trunc('week', created_at) wk, sum(amount) v from bonus_transactions
                where type in ('signup','referral') and created_at >= now()-interval '8 weeks' group by 1)
      select to_char(weeks.wk,'DD.MM') as label,
             (coalesce(rev.v,0)+coalesce(sub.v,0))::text  as revenue,
             (coalesce(mext.v,0)+coalesce(mbon.v,0))::text as marketing
        from weeks
        left join rev  on rev.wk  = weeks.wk
        left join sub  on sub.wk  = weeks.wk
        left join mext on mext.wk = weeks.wk
        left join mbon on mbon.wk = weeks.wk
       order by weeks.wk
    `),
  ]);

  const m = mrrRow.rows[0] ?? {};
  const net = netRow.rows[0] ?? {};
  const ch = churnRow.rows[0] ?? {};
  const lt = ltvRow.rows[0] ?? {};
  const cc = cacRow.rows[0] ?? {};

  const mrr = num(m.mrr);
  const topup30 = num(net.topup_30d);
  const sub30 = num(net.sub_30d);
  const extSpend30 = num(net.ext_spend_30d);
  const bonusSpend30 = num(net.bonus_spend_30d);
  const revenue30 = topup30 + sub30;
  const marketing30 = extSpend30 + bonusSpend30;
  const ltvTotal = num(lt.ltv_total);
  const cac = num(cc.cac);

  return {
    mrr,
    arr: mrr * 12,
    active_subs: num(m.active_subs),
    arpa: num(m.arpa),
    revenue_30d: revenue30,
    topup_30d: topup30,
    sub_30d: sub30,
    ext_spend_30d: extSpend30,
    bonus_spend_30d: bonusSpend30,
    marketing_30d: marketing30,
    net_profit_30d: revenue30 - marketing30,
    net_margin_pct: pct(revenue30 - marketing30, revenue30),
    weekly: weeklyRows.rows.map((r) => ({
      label: r.label, revenue: num(r.revenue), marketing: num(r.marketing),
    })),
    churn_base: num(ch.base),
    churn_pct: pct(num(ch.churned), num(ch.base)),
    paying_users: num(lt.paying_users),
    ltv_subscriptions: num(lt.ltv_sub),
    ltv_topups: num(lt.ltv_topup),
    ltv_total: ltvTotal,
    new_paying_30d: num(cc.new_paying),
    cac,
    ltv_cac: cac > 0 ? Math.round((ltvTotal / cac) * 10) / 10 : 0, // здоровье бизнеса: > 3
  };
}

// ── Marketing: гео / город / язык ──
export async function geo() {
  const breakdown = async (col: string) => {
    const { rows } = await query<{ k: string; n: string }>(
      `select coalesce(nullif(${col},''),'—') k, count(*)::text n
         from users group by 1 order by count(*) desc limit 15`,
    );
    const total = rows.reduce((s, r) => s + num(r.n), 0) || 1;
    return rows.map((r) => ({ key: r.k, count: num(r.n), pct: pct(num(r.n), total) }));
  };
  const [countries, cities, locales] = await Promise.all([
    breakdown('country'),
    breakdown('city'),
    breakdown('locale'),
  ]);
  return { countries, cities, locales };
}

// ── Marketing: конверсия контента + рейтинг провайдеров + топ-идеи ──
export async function content() {
  const [courses, providers, ideas] = await Promise.all([
    // Конверсия курсов: просмотр карточки (activity_events) → покупка
    query<Record<string, string>>(`
      select c.id, coalesce(c.title->>'ru', c.title->>'kk', c.id) as title,
             count(distinct a.user_id) filter (where a.event='view_course') as views,
             count(distinct cp.user_id) as buyers
        from course_catalog c
        left join activity_events a on a.entity_type='course' and a.entity_id = c.id
        left join course_purchases cp on cp.course_id = c.id
       where c.is_published
       group by c.id, title
       order by buyers desc, views desc
       limit 20
    `),
    // Рейтинг провайдеров: подписчики + retention (provider_subscription_events)
    query<Record<string, string>>(`
      select p.id, p.name, p.subscribers, p.verified,
             count(*) filter (where e.action='subscribe'   and e.created_at >= now()-interval '30 days') as new_subs_30d,
             count(*) filter (where e.action='unsubscribe' and e.created_at >= now()-interval '30 days') as lost_30d
        from signal_providers p
        left join provider_subscription_events e on e.provider_id = p.id
       group by p.id
       order by p.subscribers desc
       limit 20
    `),
    // Самые открываемые идеи: платные открытия + голоса (прокси «открыл»)
    query<Record<string, string>>(`
      select s.id, s.pair, s.direction, s.status,
             count(distinct sp.user_id) as paid_opens,
             count(distinct v.user_id)  as voters
        from signals s
        left join signal_purchases sp on sp.signal_id = s.id
        left join signal_votes v on v.signal_id = s.id
       where s.deleted_at is null
       group by s.id
       order by paid_opens desc, voters desc
       limit 20
    `),
  ]);

  return {
    courses: courses.rows.map((r) => ({
      id: r.id, title: r.title, views: num(r.views), buyers: num(r.buyers),
      cvr_pct: pct(num(r.buyers), num(r.views)),
    })),
    providers: providers.rows.map((r) => ({
      id: r.id, name: r.name, subscribers: num(r.subscribers), verified: String(r.verified) === 'true' || String(r.verified) === 't',
      new_subs_30d: num(r.new_subs_30d), lost_30d: num(r.lost_30d),
      retention_pct: Math.max(0, Math.round((1 - num(r.lost_30d) / Math.max(num(r.subscribers), 1)) * 1000) / 10),
    })),
    ideas: ideas.rows.map((r) => ({
      id: r.id, pair: r.pair, direction: r.direction, status: r.status,
      paid_opens: num(r.paid_opens), voters: num(r.voters),
    })),
  };
}

// ── Cohort retention (по неделям регистрации) — из activity_events ──
// Матрица: cohort × week_no → % удержания. До накопления данных будет разреженной.
export async function cohorts() {
  const { rows } = await query<Record<string, string>>(`
    with cohorts as (
      select u.id, date_trunc('week', u.created_at) coh
        from users u where u.created_at >= now() - interval '8 weeks'
    ),
    sizes as (select coh, count(*) sz from cohorts group by coh),
    act as (
      select c.coh,
             (floor(extract(epoch from (date_trunc('week', a.created_at) - c.coh)) / 604800))::int wk,
             c.id uid
        from cohorts c
        join activity_events a on a.user_id = c.id and a.created_at >= c.coh
       group by c.coh, wk, c.id
    )
    select to_char(a.coh,'YYYY-MM-DD') as cohort, a.wk as week_no,
           count(distinct a.uid) as active, s.sz as cohort_size
      from act a join sizes s on s.coh = a.coh
     where a.wk between 0 and 7
     group by a.coh, a.wk, s.sz
     order by a.coh, a.wk
  `);
  // Pivot в JS: { cohort, size, weeks: {0:100, 1:62, ...} }
  const byCohort = new Map<string, { cohort: string; size: number; weeks: Record<number, number> }>();
  for (const r of rows) {
    const c = r.cohort;
    if (!byCohort.has(c)) byCohort.set(c, { cohort: c, size: num(r.cohort_size), weeks: {} });
    const entry = byCohort.get(c)!;
    entry.weeks[num(r.week_no)] = pct(num(r.active), num(r.cohort_size));
  }
  return { cohorts: Array.from(byCohort.values()) };
}

// ── Overview: заголовочные KPI (engagement + finance headline) одним вызовом ──
export async function overview() {
  const [eng, fin] = await Promise.all([engagement(), finance()]);
  return {
    dau: eng.dau,
    mau: eng.mau,
    stickiness_pct: eng.stickiness_pct,
    mrr: fin.mrr,
    arr: fin.arr,
    net_margin_pct: fin.net_margin_pct,
    ltv_cac: fin.ltv_cac,
    churn_pct: fin.churn_pct,
    paying_users: fin.paying_users,
  };
}
