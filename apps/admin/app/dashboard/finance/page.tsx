'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Stats = {
  topup_total: string; topup_count: string; topup_7d: string;
  course_sales: string; course_bonus: string;
  idea_sales: string; signal_bonus: string;
  referral_total: string; referral_count: string; signup_total: string;
  bonus_issued: string; bonus_outstanding: string;
};

type Tx = {
  id: string; type: string; amount: number; ref: string | null;
  created_at: string; phone: string; name: string | null;
};

// Әр транзакция түрінің қаржылық мағынасы — қате түсінбеу үшін АЙҚЫН белгі.
type Kind = 'income' | 'realization' | 'marketing';
const TX_META: Record<string, { label: string; tag: string; kind: Kind }> = {
  topup: { label: '💳 Пополнение', tag: 'доход · Kaspi', kind: 'income' },
  spend_course: { label: '🎓 Покупка курса', tag: 'реализация', kind: 'realization' },
  spend_signal: { label: '📈 Покупка идеи', tag: 'реализация', kind: 'realization' },
  referral: { label: '🎁 Реферальный бонус', tag: 'расход · маркетинг', kind: 'marketing' },
  signup: { label: '✨ Бонус за регистрацию', tag: 'расход · маркетинг', kind: 'marketing' },
};
const KIND_COLOR: Record<Kind, string> = {
  income: '#059669', // зелёный — реальные деньги
  realization: '#2563EB', // синий — внутренний оборот (бонусы списаны)
  marketing: '#D97706', // янтарный — расход на маркетинг (бонусы выданы бесплатно)
};

const FILTERS = [
  { v: 'all', label: 'Все' },
  { v: 'topup', label: '💳 Пополнения' },
  { v: 'referral', label: '🎁 Рефералка' },
  { v: 'signup', label: '✨ Регистрации' },
  { v: 'spend_course', label: '🎓 Курсы' },
  { v: 'spend_signal', label: '📈 Идеи' },
];

export default function FinancePage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [txs, setTxs] = useState<Tx[]>([]);
  const [filter, setFilter] = useState('all');
  const [err, setErr] = useState('');

  useEffect(() => {
    api<{ stats: Stats }>('/admin/stats').then((r) => setStats(r.stats)).catch((e) => setErr(e.message));
  }, []);

  useEffect(() => {
    const q = filter === 'all' ? '' : `&type=${filter}`;
    api<{ transactions: Tx[] }>(`/admin/bonus/transactions?limit=100${q}`)
      .then((r) => setTxs(r.transactions))
      .catch((e) => setErr(e.message));
  }, [filter]);

  const tg = (v?: string | number) => `${Number(v ?? 0).toLocaleString('ru-RU')} ₸`;
  const n = (v?: string | number) => Number(v ?? 0).toLocaleString('ru-RU');
  const avg = stats && Number(stats.topup_count) > 0 ? Number(stats.topup_total) / Number(stats.topup_count) : 0;

  return (
    <div>
      <h1>💰 Финансы и бонусы</h1>
      <p className="muted">
        1 бонус = 1 ₸. <b style={{ color: KIND_COLOR.income }}>Доход</b> — реальные деньги (пополнения Kaspi).{' '}
        <b style={{ color: KIND_COLOR.marketing }}>Расход</b> — бонусы, выданные бесплатно (рефералка, регистрация).{' '}
        <b style={{ color: KIND_COLOR.realization }}>Реализация</b> — на что потрачены бонусы.
      </p>
      {err && <div className="err">{err}</div>}

      {/* ── ДОХОД (реальные деньги) ── */}
      <h2 style={{ marginTop: 24, color: KIND_COLOR.income }}>📈 Доход — реальные деньги (Kaspi)</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
        <Card label="Выручка, всего" value={tg(stats?.topup_total)} color={KIND_COLOR.income} big />
        <Card label="Выручка за 7 дней" value={tg(stats?.topup_7d)} color={KIND_COLOR.income} />
        <Card label="Пополнений" value={n(stats?.topup_count)} hint="транзакций" />
        <Card label="Средний чек" value={tg(Math.round(avg))} hint="на пополнение" />
      </div>

      {/* ── РЕАЛИЗАЦИЯ (бонусы потрачены) ── */}
      <h2 style={{ marginTop: 28, color: KIND_COLOR.realization }}>🛒 Реализация — на что потрачены бонусы</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
        <Card label="Продажи курсов" value={n(stats?.course_sales)} hint={`${tg(stats?.course_bonus)} списано`} color={KIND_COLOR.realization} />
        <Card label="Продажи идей" value={n(stats?.idea_sales)} hint={`${tg(stats?.signal_bonus)} списано`} color={KIND_COLOR.realization} />
        <Card label="Всего реализовано" value={tg(Number(stats?.course_bonus ?? 0) + Number(stats?.signal_bonus ?? 0))} hint="бонусов потрачено" color={KIND_COLOR.realization} />
      </div>

      {/* ── РАСХОД (маркетинг — бонусы выданы) ── */}
      <h2 style={{ marginTop: 28, color: KIND_COLOR.marketing }}>🎁 Расход — маркетинг (бонусы выданы бесплатно)</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
        <Card label="Рефералка (выдано)" value={tg(stats?.referral_total)} hint={`${n(stats?.referral_count)} начислений`} color={KIND_COLOR.marketing} />
        <Card label="За регистрацию/промо" value={tg(stats?.signup_total)} color={KIND_COLOR.marketing} />
        <Card label="Всего выдано" value={tg(stats?.bonus_issued)} hint="маркетинговый расход" color={KIND_COLOR.marketing} big />
        <Card label="Бонусов на балансах" value={tg(stats?.bonus_outstanding)} hint="обязательства (в обороте)" />
      </div>

      {/* ── Транзакции ── */}
      <h2 style={{ marginTop: 28 }}>Операции с бонусами</h2>
      <div className="row" style={{ gap: 8, flexWrap: 'wrap', marginBottom: 10 }}>
        {FILTERS.map((f) => (
          <button
            key={f.v}
            className={filter === f.v ? '' : 'ghost'}
            style={{ padding: '6px 12px', fontSize: 13 }}
            onClick={() => setFilter(f.v)}
          >
            {f.label}
          </button>
        ))}
      </div>
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead>
            <tr style={{ textAlign: 'left', color: 'var(--muted)' }}>
              <th style={{ padding: '10px 14px' }}>Операция</th>
              <th style={{ padding: '10px 14px' }}>Категория</th>
              <th style={{ padding: '10px 14px' }}>Пользователь</th>
              <th style={{ padding: '10px 14px' }}>Сумма</th>
              <th style={{ padding: '10px 14px' }}>Дата</th>
            </tr>
          </thead>
          <tbody>
            {txs.length === 0 && (
              <tr><td colSpan={5} style={{ padding: 16, color: 'var(--muted)' }}>Нет операций</td></tr>
            )}
            {txs.map((t) => {
              const m = TX_META[t.type] ?? { label: t.type, tag: '—', kind: 'realization' as Kind };
              const color = KIND_COLOR[m.kind];
              return (
                <tr key={t.id} style={{ borderTop: '1px solid var(--border)' }}>
                  <td style={{ padding: '10px 14px' }}>{m.label}</td>
                  <td style={{ padding: '10px 14px' }}>
                    <span style={{ fontSize: 11, fontWeight: 700, color, background: `${color}1a`, padding: '3px 8px', borderRadius: 20 }}>
                      {m.tag}
                    </span>
                  </td>
                  <td style={{ padding: '10px 14px' }}>{t.name || t.phone}</td>
                  <td style={{ padding: '10px 14px', fontWeight: 700, color }}>
                    {t.amount >= 0 ? '+' : ''}{t.amount.toLocaleString('ru-RU')} ₸
                  </td>
                  <td style={{ padding: '10px 14px', color: 'var(--muted)' }}>
                    {new Date(t.created_at).toLocaleString('ru-RU', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function Card({ label, value, hint, color, big }: { label: string; value: string; hint?: string; color?: string; big?: boolean }) {
  return (
    <div className="card">
      <div className="muted" style={{ fontSize: 12 }}>{label}</div>
      <div style={{ fontSize: big ? 30 : 24, fontWeight: 800, color: color ?? 'var(--text)' }}>{value}</div>
      {hint && <div className="muted" style={{ fontSize: 11, marginTop: 2 }}>{hint}</div>}
    </div>
  );
}
