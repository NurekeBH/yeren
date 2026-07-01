import type { FastifyBaseLogger } from 'fastify';
import { query } from '../db/client.js';

// Medallion ETL: Bronze → Silver (дедуп) → Gold (витрины). Строго ИДЕМПОТЕНТНО:
// повторный прогон за тот же период не дублирует и не искажает (on conflict / upsert).

// ── Bronze → Silver (дедуп по event_id; окно с запасом → идемпотентно) ──
async function bronzeToSilver(): Promise<void> {
  // Логи активности (для streak/retention). event_id или синтетический 'b<id>'.
  await query(`
    insert into silver_user_activity (event_id, user_id, event, activity_date, occurred_at, device)
    select coalesce(b.event_id, 'b' || b.id), b._user_id, b.event,
           (coalesce(b._client_ts, b._ingested_at))::date,
           coalesce(b._client_ts, b._ingested_at), b._source_device
      from bronze_events b
     where b._ingested_at > now() - interval '2 hours' and b._user_id is not null
    on conflict (event_id) do nothing
  `);
  // Клики по промо-ссылке (из bronze-события 'invite_click').
  await query(`
    insert into silver_referral_clicks (event_id, code, user_id, clicked_at)
    select coalesce(b.event_id, 'b' || b.id), upper(b.payload->>'code'), b._user_id,
           coalesce(b._client_ts, b._ingested_at)
      from bronze_events b
     where b.event = 'invite_click' and b.payload->>'code' is not null
       and b._ingested_at > now() - interval '2 hours'
    on conflict (event_id) do nothing
  `);
  // Отмечаем клики, которые дошли до регистрации (по промокоду → users.referred_by).
  await query(`
    update silver_referral_clicks s set registered = true
     where s.registered = false
       and exists (select 1 from users u where upper(u.referred_by) = s.code)
  `);
}

// ── Gold: воронка роста (по дням, за 90 дней). Идемпотентный upsert. ──
async function refreshGrowthFunnel(): Promise<void> {
  await query(`
    insert into gold_growth_funnel (date, total_clicks, successful_registrations_via_promo, conversion_rate, k_factor, refreshed_at)
    select d::date,
           coalesce(cl.clicks, 0) as total_clicks,
           coalesce(rg.regs, 0)   as regs,
           round(100.0 * coalesce(rg.regs,0) / nullif(coalesce(cl.clicks,0), 0), 2)      as conversion_rate,
           round(coalesce(rg.regs,0)::numeric / nullif(coalesce(cl.referrers,0), 0), 3)  as k_factor
      from generate_series(now()::date - interval '89 days', now()::date, interval '1 day') d
      left join (
        select created_at::date dt, count(*) clicks, count(distinct code) referrers
          from referral_clicks group by 1
      ) cl on cl.dt = d::date
      left join (
        select created_at::date dt, count(*) regs
          from users where coalesce(referred_by,'') <> '' group by 1
      ) rg on rg.dt = d::date
    on conflict (date) do update set
      total_clicks = excluded.total_clicks,
      successful_registrations_via_promo = excluded.successful_registrations_via_promo,
      conversion_rate = excluded.conversion_rate,
      k_factor = excluded.k_factor,
      refreshed_at = now()
  `);
}

// ── Gold: эффективность трейдеров. С ВАЛИДАЦИЕЙ АНОМАЛИЙ (win_rate>100 / earned<0). ──
async function refreshTraderPerformance(log?: FastifyBaseLogger): Promise<void> {
  const { rows } = await query<Record<string, string>>(`
    select s.created_by as trader_id,
           count(*) filter (where s.deleted_at is null) as total_signals,
           round(100.0 * count(*) filter (where s.status in ('closed_tp1','closed_tp2','closed_tp3'))
                 / nullif(count(*) filter (where s.status in ('closed_tp1','closed_tp2','closed_tp3','closed_sl')), 0), 2) as win_rate,
           coalesce((select sum(sp.price_tg) from signal_purchases sp
                       join signals s2 on s2.id = sp.signal_id where s2.created_by = s.created_by), 0)
         + coalesce((select sum(cp.bonus_used) from course_purchases cp
                       join course_catalog cc on cc.id = cp.course_id where cc.owner_id = s.created_by), 0) as earned
      from signals s
     where s.created_by is not null
     group by s.created_by
  `);

  for (const r of rows) {
    const winRate = Number(r.win_rate ?? 0);
    const earned = Number(r.earned ?? 0);
    // DATA QUALITY: аномалия → лог + ПРОПУСК строки (не портим витрину).
    if (winRate > 100 || winRate < 0 || earned < 0) {
      log?.error({ trader_id: r.trader_id, winRate, earned }, 'gold_anomaly_skipped');
      continue;
    }
    await query(
      `insert into gold_trader_performance (trader_id, total_signals_sent, win_rate_percentage, total_bonus_earned, refreshed_at)
       values ($1, $2, $3, $4, now())
       on conflict (trader_id) do update set
         total_signals_sent = excluded.total_signals_sent,
         win_rate_percentage = excluded.win_rate_percentage,
         total_bonus_earned = excluded.total_bonus_earned,
         refreshed_at = now()`,
      [r.trader_id, Number(r.total_signals ?? 0), winRate, earned],
    );
  }
}

// ── Gold: когорты удержания (по дню регистрации, D+1/3/7/30). ──
// Источник активности — activity_events (накапливается). Идемпотентный upsert.
async function refreshRetentionCohorts(): Promise<void> {
  await query(`
    with cohort as (
      select id, created_at::date d from users where created_at >= now() - interval '90 days'
    ),
    act as (
      select distinct user_id, created_at::date ad
        from activity_events where created_at >= now() - interval '90 days'
    ),
    joined as (
      select c.d cohort_date, c.id,
             max(case when a.ad = c.d + 1  then 1 else 0 end) d1,
             max(case when a.ad = c.d + 3  then 1 else 0 end) d3,
             max(case when a.ad = c.d + 7  then 1 else 0 end) d7,
             max(case when a.ad = c.d + 30 then 1 else 0 end) d30
        from cohort c left join act a on a.user_id = c.id
       group by c.d, c.id
    )
    insert into gold_retention_cohorts (cohort_date, cohort_size, day1_pct, day3_pct, day7_pct, day30_pct, refreshed_at)
    select cohort_date, count(*),
           round(100.0*sum(d1)/nullif(count(*),0),2),
           round(100.0*sum(d3)/nullif(count(*),0),2),
           round(100.0*sum(d7)/nullif(count(*),0),2),
           round(100.0*sum(d30)/nullif(count(*),0),2),
           now()
      from joined group by cohort_date
    on conflict (cohort_date) do update set
      cohort_size = excluded.cohort_size,
      day1_pct = excluded.day1_pct, day3_pct = excluded.day3_pct,
      day7_pct = excluded.day7_pct, day30_pct = excluded.day30_pct,
      refreshed_at = now()
  `);
}

/** Полный прогон ETL (ежечасно). Каждый шаг идемпотентен. */
export async function runEtl(log?: FastifyBaseLogger): Promise<void> {
  await bronzeToSilver();
  await refreshGrowthFunnel();
  await refreshTraderPerformance(log);
  await refreshRetentionCohorts();
  log?.info('etl_run_complete');
}
