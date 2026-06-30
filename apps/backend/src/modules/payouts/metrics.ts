// Дашборд трейдера (провайдера) + баланс/выплаты.
// Заработок трейдера = продажи его сигналов (signal_purchases по signals.created_by)
// + продажи его курсов (course_purchases по course_catalog.owner_id), в ₸ (бонус 1:1).
// Баланс ВЫЧИСЛЯЕМЫЙ: earned − paid(provider_payouts) = available.
import { query } from '../../db/client.js';

const num = (v: unknown): number => Number(v ?? 0);

// Период фильтра дохода → интервал. 'all' = практически без границы.
const PERIOD: Record<string, string> = {
  day: '1 day', week: '7 days', month: '30 days', year: '365 days', all: '36500 days',
};

export type DashPeriod = 'day' | 'week' | 'month' | 'year' | 'all';

/** Полный дашборд трейдера. userId — id трейдера (верифицированного). */
export async function providerDashboard(userId: string, period: DashPeriod) {
  const interval = PERIOD[period] ?? PERIOD.month;

  // Промокод трейдера (для рефералки) + provider_id.
  const meRow = await query<{ promo_code: string | null; provider_id: string | null }>(
    `select u.promo_code, p.id as provider_id
       from users u left join signal_providers p on p.user_id = u.id
      where u.id = $1`,
    [userId],
  );
  const promo = meRow.rows[0]?.promo_code ?? '';
  const providerId = meRow.rows[0]?.provider_id ?? null;

  const [sigSales, courseSales, incomeRow, series, refRow, paidRow, payouts] = await Promise.all([
    // 1. Продажи сигналов — детализация по каждому (за всё время)
    query<Record<string, string>>(`
      select s.id, s.pair, s.direction, s.status, s.published_at,
             count(sp.user_id)::text as buyers, coalesce(sum(sp.price_tg),0)::text as revenue
        from signals s
        left join signal_purchases sp on sp.signal_id = s.id
       where s.created_by = $1 and s.deleted_at is null
       group by s.id
       order by s.published_at desc nulls last
       limit 100
    `, [userId]),
    // 2. Продажи курсов — по каждому курсу (за всё время)
    query<Record<string, string>>(`
      select c.id, coalesce(c.title->>'ru', c.title->>'kk', c.id) as title,
             count(cp.user_id)::text as buyers, coalesce(sum(cp.bonus_used),0)::text as revenue
        from course_catalog c
        left join course_purchases cp on cp.course_id = c.id
       where c.owner_id = $1
       group by c.id
       order by c.created_at desc
    `, [userId]),
    // 3. Доход за выбранный период (сигналы vs курсы)
    query<Record<string, string>>(`
      select
        (select coalesce(sum(sp.price_tg),0) from signal_purchases sp
            join signals s on s.id = sp.signal_id
           where s.created_by = $1 and sp.created_at >= now() - $2::interval) as signals,
        (select coalesce(sum(cp.bonus_used),0) from course_purchases cp
            join course_catalog c on c.id = cp.course_id
           where c.owner_id = $1 and cp.created_at >= now() - $2::interval) as courses
    `, [userId, interval]),
    // 4. Тренд за 30 дней (дневная серия): сигналы vs курсы
    query<Record<string, string>>(`
      with days as (
        select generate_series(date_trunc('day', now()) - interval '29 days', date_trunc('day', now()), interval '1 day') as d
      ),
      sig as (select date_trunc('day', sp.created_at) d, sum(sp.price_tg) v
                from signal_purchases sp join signals s on s.id = sp.signal_id
               where s.created_by = $1 and sp.created_at >= now() - interval '30 days' group by 1),
      crs as (select date_trunc('day', cp.created_at) d, sum(cp.bonus_used) v
                from course_purchases cp join course_catalog c on c.id = cp.course_id
               where c.owner_id = $1 and cp.created_at >= now() - interval '30 days' group by 1)
      select to_char(days.d, 'DD.MM') as label,
             coalesce(sig.v,0)::text as signals, coalesce(crs.v,0)::text as courses
        from days
        left join sig on sig.d = days.d
        left join crs on crs.d = days.d
       order by days.d
    `, [userId]),
    // 5. Рефералы по промокоду: зарегистрировались / из них активные (сделали покупку)
    query<Record<string, string>>(`
      with refs as (select id from users where referred_by = $1 and $1 <> '')
      select
        (select count(*) from refs) as registered,
        (select count(*) from refs r where exists (
            select 1 from signal_purchases sp where sp.user_id = r.id)
          or exists (select 1 from course_purchases cp where cp.user_id = r.id)
          or exists (select 1 from bonus_transactions bt where bt.user_id = r.id and bt.type = 'topup')
        ) as active
    `, [promo]),
    // 6. Уже выплачено
    query<{ paid: string }>('select coalesce(sum(amount),0)::text as paid from provider_payouts where user_id = $1', [userId]),
    // 7. История выплат
    query<Record<string, string>>(`
      select id, amount::text as amount, currency, method, note, created_at
        from provider_payouts where user_id = $1 order by created_at desc limit 100
    `, [userId]),
  ]);

  const signalsList = sigSales.rows.map((r) => ({
    id: r.id, pair: r.pair, direction: r.direction, status: r.status,
    published_at: r.published_at, buyers: num(r.buyers), revenue: num(r.revenue),
  }));
  const coursesList = courseSales.rows.map((r) => ({
    id: r.id, title: r.title, buyers: num(r.buyers), revenue: num(r.revenue),
  }));

  const signalsRevenueTotal = signalsList.reduce((s, x) => s + x.revenue, 0);
  const coursesRevenueTotal = coursesList.reduce((s, x) => s + x.revenue, 0);
  const earned = signalsRevenueTotal + coursesRevenueTotal;
  const paid = num(paidRow.rows[0]?.paid);

  const inc = incomeRow.rows[0] ?? {};
  const ref = refRow.rows[0] ?? {};

  return {
    period,
    balance: { earned, paid, available: Math.max(0, earned - paid) },
    signal_sales: {
      total_buyers: signalsList.reduce((s, x) => s + x.buyers, 0),
      total_revenue: signalsRevenueTotal,
      items: signalsList,
    },
    course_sales: {
      total_buyers: coursesList.reduce((s, x) => s + x.buyers, 0),
      total_revenue: coursesRevenueTotal,
      items: coursesList,
    },
    income: {
      signals: num(inc.signals),
      courses: num(inc.courses),
      total: num(inc.signals) + num(inc.courses),
    },
    trend: series.rows.map((r) => ({ label: r.label, signals: num(r.signals), courses: num(r.courses) })),
    referrals: { registered: num(ref.registered), active: num(ref.active) },
    payouts: payouts.rows.map((r) => ({
      id: r.id, amount: num(r.amount), currency: r.currency, method: r.method, note: r.note, created_at: r.created_at,
    })),
    provider_id: providerId,
  };
}

/** Админ: список трейдеров с балансами (earned/paid/available) для раздела выплат. */
export async function adminPayoutsOverview() {
  const { rows } = await query<Record<string, string>>(`
    with sig as (
      select s.created_by uid, coalesce(sum(sp.price_tg),0) v
        from signals s join signal_purchases sp on sp.signal_id = s.id
       where s.created_by is not null group by s.created_by
    ), crs as (
      select c.owner_id uid, coalesce(sum(cp.bonus_used),0) v
        from course_catalog c join course_purchases cp on cp.course_id = c.id
       where c.owner_id is not null group by c.owner_id
    ), paid as (
      select user_id uid, coalesce(sum(amount),0) v from provider_payouts group by user_id
    )
    select p.id as provider_id, p.user_id, p.name, p.avatar,
           coalesce(sig.v,0)::text as signals_rev,
           coalesce(crs.v,0)::text as courses_rev,
           coalesce(paid.v,0)::text as paid
      from signal_providers p
      left join sig  on sig.uid  = p.user_id
      left join crs  on crs.uid  = p.user_id
      left join paid on paid.uid = p.user_id
     where p.user_id is not null
     order by (coalesce(sig.v,0) + coalesce(crs.v,0) - coalesce(paid.v,0)) desc
  `);
  return {
    providers: rows.map((r) => {
      const earned = num(r.signals_rev) + num(r.courses_rev);
      const paid = num(r.paid);
      return {
        provider_id: r.provider_id, user_id: r.user_id, name: r.name, avatar: r.avatar,
        signals_rev: num(r.signals_rev), courses_rev: num(r.courses_rev),
        earned, paid, available: Math.max(0, earned - paid),
      };
    }),
  };
}

/** История выплат одного трейдера (для админ-карточки). */
export async function providerPayoutHistory(userId: string) {
  const { rows } = await query<Record<string, string>>(`
    select id, amount::text as amount, currency, method, note, created_at, paid_by
      from provider_payouts where user_id = $1 order by created_at desc limit 200
  `, [userId]);
  return { payouts: rows.map((r) => ({ ...r, amount: num(r.amount) })) };
}
