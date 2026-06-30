'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';
import { Donut, LineChart, BarPair } from '@/components/charts';

type Stats = {
  topup_total: string; topup_count: string; topup_7d: string;
  course_sales: string; course_bonus: string;
  idea_sales: string; signal_bonus: string;
  referral_total: string; referral_count: string; signup_total: string;
  bonus_issued: string; bonus_outstanding: string;
};

type Fin = {
  mrr: number; arr: number; active_subs: number; arpa: number;
  revenue_30d: number; topup_30d: number; sub_30d: number;
  ext_spend_30d: number; bonus_spend_30d: number; marketing_30d: number;
  net_profit_30d: number; net_margin_pct: number;
  weekly: { label: string; revenue: number; marketing: number }[];
  churn_pct: number; churn_base: number;
  paying_users: number; ltv_subscriptions: number; ltv_topups: number; ltv_total: number;
  new_paying_30d: number; cac: number; ltv_cac: number;
};

type Spend = {
  id: string; channel: string; campaign: string | null;
  amount_kzt: number; spent_on: string; city: string | null; note: string | null;
};

type Tx = {
  id: string; type: string; amount: number; ref: string | null;
  created_at: string; phone: string; name: string | null;
};

type Kind = 'income' | 'realization' | 'marketing';
const TX_META: Record<string, { label: string; tag: string; kind: Kind }> = {
  topup: { label: '💳 Пополнение', tag: 'доход · Kaspi', kind: 'income' },
  spend_course: { label: '🎓 Покупка курса', tag: 'реализация', kind: 'realization' },
  spend_signal: { label: '📈 Покупка идеи', tag: 'реализация', kind: 'realization' },
  referral: { label: '🎁 Реферальный бонус', tag: 'расход · маркетинг', kind: 'marketing' },
  signup: { label: '✨ Бонус за регистрацию', tag: 'расход · маркетинг', kind: 'marketing' },
};
const KIND_COLOR: Record<Kind, string> = { income: '#059669', realization: '#2563EB', marketing: '#D97706' };

const FILTERS = [
  { v: 'all', label: 'Все' },
  { v: 'topup', label: '💳 Пополнения' },
  { v: 'referral', label: '🎁 Рефералка' },
  { v: 'signup', label: '✨ Регистрации' },
  { v: 'spend_course', label: '🎓 Курсы' },
  { v: 'spend_signal', label: '📈 Идеи' },
];

const CHANNELS = ['instagram', 'google', 'tiktok', 'influencer', 'other'];

export default function FinancePage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [fin, setFin] = useState<Fin | null>(null);
  const [spend, setSpend] = useState<Spend[]>([]);
  const [txs, setTxs] = useState<Tx[]>([]);
  const [filter, setFilter] = useState('all');
  const [err, setErr] = useState('');

  // Форма расхода
  const [channel, setChannel] = useState('instagram');
  const [amount, setAmount] = useState('');
  const [spentOn, setSpentOn] = useState(() => new Date().toISOString().slice(0, 10));
  const [campaign, setCampaign] = useState('');
  const [city, setCity] = useState('');
  const [saving, setSaving] = useState(false);

  const loadSpend = () =>
    api<{ items: Spend[] }>('/admin/marketing-spend').then((r) => setSpend(r.items)).catch(() => {});

  useEffect(() => {
    api<{ stats: Stats }>('/admin/stats').then((r) => setStats(r.stats)).catch((e) => setErr(e.message));
    api<Fin>('/admin/bi/finance').then(setFin).catch((e) => setErr(e.message));
    loadSpend();
  }, []);

  useEffect(() => {
    const q = filter === 'all' ? '' : `&type=${filter}`;
    api<{ transactions: Tx[] }>(`/admin/bonus/transactions?limit=100${q}`)
      .then((r) => setTxs(r.transactions))
      .catch((e) => setErr(e.message));
  }, [filter]);

  const tg = (v?: number | string) => `${Number(v ?? 0).toLocaleString('ru-RU')} ₸`;
  const n = (v?: number | string) => Number(v ?? 0).toLocaleString('ru-RU');

  const addSpend = async () => {
    const amt = Number(amount);
    if (!amt || amt <= 0) return setErr('Укажите сумму расхода');
    setSaving(true);
    try {
      await api('/admin/marketing-spend', {
        method: 'POST',
        body: { channel, amount_kzt: amt, spent_on: spentOn, campaign: campaign || undefined, city: city || undefined },
      });
      setAmount(''); setCampaign(''); setCity('');
      await loadSpend();
      api<Fin>('/admin/bi/finance').then(setFin).catch(() => {}); // CAC пересчитать
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setSaving(false);
    }
  };

  const delSpend = async (id: string) => {
    await api(`/admin/marketing-spend/${id}`, { method: 'DELETE' }).catch(() => {});
    await loadSpend();
  };

  const healthColor = (ratio: number) => (ratio >= 3 ? '#059669' : ratio >= 1 ? '#D97706' : '#DC2626');

  return (
    <div>
      <h1>💰 Финансы · P&L</h1>
      <p className="muted">
        1 бонус = 1 ₸. Реальные деньги — пополнения Kaspi и подписки. Курсы/идеи списывают бонус (оборот).
        Выданные signup/referral бонусы — маркетинг-расход.
      </p>
      {err && <div className="err">{err}</div>}

      {/* ── P&L сводка (30 дней) ── */}
      <div className="card" style={{ marginTop: 16, display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 16 }}>
        <PL label="Выручка (30д)" value={tg(fin?.revenue_30d)} color="#059669" />
        <span style={{ fontSize: 26, color: 'var(--muted)' }}>−</span>
        <PL label="Маркетинг (30д)" value={tg(fin?.marketing_30d)} color="#D97706" />
        <span style={{ fontSize: 26, color: 'var(--muted)' }}>=</span>
        <PL label="Чистая прибыль (30д)" value={tg(fin?.net_profit_30d)} color={(fin?.net_profit_30d ?? 0) >= 0 ? '#059669' : '#DC2626'} big />
        <PL label="Маржа" value={`${fin?.net_margin_pct ?? 0}%`} color={(fin?.net_margin_pct ?? 0) >= 0 ? '#059669' : '#DC2626'} />
      </div>

      {/* ── Главные KPI бизнеса ── */}
      <h2 style={{ marginTop: 24 }}>📊 Ключевые показатели</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
        <Card label="MRR" value={tg(fin?.mrr)} hint={`ARR ${tg(fin?.arr)}`} color="#059669" big />
        <Card label="Активные подписки" value={n(fin?.active_subs)} hint={`ARPA ${tg(fin?.arpa)}`} />
        <Card label="LTV / CAC" value={`${fin?.ltv_cac ?? 0}×`} hint="норма > 3" color={healthColor(fin?.ltv_cac ?? 0)} big />
        <Card label="Churn (мес.)" value={`${fin?.churn_pct ?? 0}%`} hint={`база ${n(fin?.churn_base)} подписок`} color={(fin?.churn_pct ?? 0) > 10 ? '#DC2626' : 'var(--text)'} />
        <Card label="LTV (всего)" value={tg(fin?.ltv_total)} hint={`подписки ${tg(fin?.ltv_subscriptions)} · топап ${tg(fin?.ltv_topups)}`} color="#2563EB" />
        <Card label="CAC" value={tg(fin?.cac)} hint={`${n(fin?.new_paying_30d)} новых платящих / 30д`} color="#D97706" />
        <Card label="Платящие" value={n(fin?.paying_users)} hint="всего за всё время" />
        <Card label="Доход 7д" value={tg(stats?.topup_7d)} hint={`${n(stats?.topup_count)} пополнений`} color="#059669" />
      </div>

      {/* ── Графики ── */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14, marginTop: 24 }}>
        <div className="card">
          <div className="muted" style={{ fontSize: 12, marginBottom: 10 }}>Структура выручки (30д)</div>
          <Donut segments={[
            { label: 'Пополнения', value: fin?.topup_30d ?? 0, color: '#059669' },
            { label: 'Подписки', value: fin?.sub_30d ?? 0, color: '#2563EB' },
          ]} />
        </div>
        <div className="card">
          <div className="muted" style={{ fontSize: 12, marginBottom: 10 }}>Выручка по неделям (8 недель)</div>
          <LineChart
            labels={(fin?.weekly ?? []).map((w) => w.label)}
            series={[{ name: 'Выручка', color: '#059669', points: (fin?.weekly ?? []).map((w) => w.revenue) }]}
          />
        </div>
      </div>
      <div className="card" style={{ marginTop: 14 }}>
        <div className="muted" style={{ fontSize: 12, marginBottom: 10 }}>Доход vs Маркетинг по неделям</div>
        <BarPair groups={(fin?.weekly ?? []).map((w) => ({ label: w.label, a: w.revenue, b: w.marketing }))} />
        <div style={{ display: 'flex', gap: 16, marginTop: 6 }}>
          <Legend color="#059669" text="Доход" />
          <Legend color="#D97706" text="Маркетинг" />
        </div>
      </div>

      {/* ── Маркетинговые затраты (CAC) ── */}
      <h2 style={{ marginTop: 28 }}>📣 Маркетинговые затраты (для CAC)</h2>
      <div className="muted" style={{ fontSize: 12, marginBottom: 10 }}>
        Внешний рекламный расход (Instagram, блогеры…). Влияет на CAC и чистую прибыль.
      </div>
      <div className="card" style={{ display: 'flex', gap: 10, flexWrap: 'wrap', alignItems: 'flex-end' }}>
        <Field label="Канал">
          <select value={channel} onChange={(e) => setChannel(e.target.value)} style={inp}>
            {CHANNELS.map((c) => <option key={c} value={c}>{c}</option>)}
          </select>
        </Field>
        <Field label="Сумма, ₸"><input value={amount} onChange={(e) => setAmount(e.target.value)} inputMode="numeric" placeholder="50000" style={inp} /></Field>
        <Field label="Дата"><input type="date" value={spentOn} onChange={(e) => setSpentOn(e.target.value)} style={inp} /></Field>
        <Field label="Кампания"><input value={campaign} onChange={(e) => setCampaign(e.target.value)} placeholder="напр. июньская акция" style={inp} /></Field>
        <Field label="Город (опц.)"><input value={city} onChange={(e) => setCity(e.target.value)} placeholder="Шымкент" style={inp} /></Field>
        <button onClick={addSpend} disabled={saving} style={{ padding: '8px 16px' }}>{saving ? '…' : 'Добавить расход'}</button>
      </div>
      <div className="card" style={{ padding: 0, overflow: 'hidden', marginTop: 12 }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead>
            <tr style={{ textAlign: 'left', color: 'var(--muted)' }}>
              <th style={th}>Канал</th><th style={th}>Кампания</th><th style={th}>Город</th><th style={th}>Сумма</th><th style={th}>Дата</th><th style={th}></th>
            </tr>
          </thead>
          <tbody>
            {spend.length === 0 && <tr><td colSpan={6} style={{ padding: 16, color: 'var(--muted)' }}>Расходов пока нет</td></tr>}
            {spend.map((s) => (
              <tr key={s.id} style={{ borderTop: '1px solid var(--border)' }}>
                <td style={td}>{s.channel}</td>
                <td style={td}>{s.campaign || '—'}</td>
                <td style={td}>{s.city || '—'}</td>
                <td style={{ ...td, fontWeight: 700, color: '#D97706' }}>{tg(s.amount_kzt)}</td>
                <td style={{ ...td, color: 'var(--muted)' }}>{new Date(s.spent_on).toLocaleDateString('ru-RU')}</td>
                <td style={td}><button className="ghost" style={{ padding: '4px 10px', fontSize: 12 }} onClick={() => delSpend(s.id)}>Удалить</button></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* ── Реализация (бонусы потрачены) ── */}
      <h2 style={{ marginTop: 28, color: KIND_COLOR.realization }}>🛒 Реализация — на что потрачены бонусы</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14 }}>
        <Card label="Продажи курсов" value={n(stats?.course_sales)} hint={`${tg(stats?.course_bonus)} списано`} color={KIND_COLOR.realization} />
        <Card label="Продажи идей" value={n(stats?.idea_sales)} hint={`${tg(stats?.signal_bonus)} списано`} color={KIND_COLOR.realization} />
        <Card label="Бонусов на балансах" value={tg(stats?.bonus_outstanding)} hint="обязательства (в обороте)" />
      </div>

      {/* ── Операции с бонусами ── */}
      <h2 style={{ marginTop: 28 }}>Операции с бонусами</h2>
      <div className="row" style={{ gap: 8, flexWrap: 'wrap', marginBottom: 10 }}>
        {FILTERS.map((f) => (
          <button key={f.v} className={filter === f.v ? '' : 'ghost'} style={{ padding: '6px 12px', fontSize: 13 }} onClick={() => setFilter(f.v)}>{f.label}</button>
        ))}
      </div>
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead>
            <tr style={{ textAlign: 'left', color: 'var(--muted)' }}>
              <th style={th}>Операция</th><th style={th}>Категория</th><th style={th}>Пользователь</th><th style={th}>Сумма</th><th style={th}>Дата</th>
            </tr>
          </thead>
          <tbody>
            {txs.length === 0 && <tr><td colSpan={5} style={{ padding: 16, color: 'var(--muted)' }}>Нет операций</td></tr>}
            {txs.map((t) => {
              const m = TX_META[t.type] ?? { label: t.type, tag: '—', kind: 'realization' as Kind };
              const color = KIND_COLOR[m.kind];
              return (
                <tr key={t.id} style={{ borderTop: '1px solid var(--border)' }}>
                  <td style={td}>{m.label}</td>
                  <td style={td}><span style={{ fontSize: 11, fontWeight: 700, color, background: `${color}1a`, padding: '3px 8px', borderRadius: 20 }}>{m.tag}</span></td>
                  <td style={td}>{t.name || t.phone}</td>
                  <td style={{ ...td, fontWeight: 700, color }}>{t.amount >= 0 ? '+' : ''}{t.amount.toLocaleString('ru-RU')} ₸</td>
                  <td style={{ ...td, color: 'var(--muted)' }}>{new Date(t.created_at).toLocaleString('ru-RU', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

const inp: React.CSSProperties = { padding: '8px 10px', borderRadius: 8, border: '1px solid var(--border)', background: 'var(--bg)', color: 'var(--text)', fontSize: 13 };
const th: React.CSSProperties = { padding: '10px 14px' };
const td: React.CSSProperties = { padding: '10px 14px' };

function Card({ label, value, hint, color, big }: { label: string; value: string; hint?: string; color?: string; big?: boolean }) {
  return (
    <div className="card">
      <div className="muted" style={{ fontSize: 12 }}>{label}</div>
      <div style={{ fontSize: big ? 28 : 22, fontWeight: 800, color: color ?? 'var(--text)' }}>{value}</div>
      {hint && <div className="muted" style={{ fontSize: 11, marginTop: 2 }}>{hint}</div>}
    </div>
  );
}

function PL({ label, value, color, big }: { label: string; value: string; color: string; big?: boolean }) {
  return (
    <div>
      <div className="muted" style={{ fontSize: 12 }}>{label}</div>
      <div style={{ fontSize: big ? 32 : 24, fontWeight: 800, color }}>{value}</div>
    </div>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <label style={{ display: 'grid', gap: 4 }}>
      <span className="muted" style={{ fontSize: 11 }}>{label}</span>
      {children}
    </label>
  );
}

function Legend({ color, text }: { color: string; text: string }) {
  return (
    <span style={{ fontSize: 12, color: 'var(--muted)', display: 'inline-flex', alignItems: 'center', gap: 6 }}>
      <span style={{ width: 10, height: 10, borderRadius: 2, background: color, display: 'inline-block' }} />{text}
    </span>
  );
}
