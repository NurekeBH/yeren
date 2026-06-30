'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';
import { LineChart } from '@/components/charts';

type Rev = {
  period: string;
  subscription: { revenue: number; payers: number; arpu: number };
  signals: { revenue: number; purchases: number; buyers: number; arpu: number };
  winner: string;
  series: { label: string; sub: number; sig: number }[];
};
type Deep = {
  whales: { user_id: string; name: string; phone: string; spent: number; signals_bought: number; last_buy: string }[];
  top_traders: { id: string; name: string; win_rate: number; purchases: number; revenue: number; buyers: number; viewers: number; conversion_pct: number | null }[];
  value_tiers: { t500: Tier; t1000: Tier };
};
type Tier = { purchases: number; revenue: number; buyers: number };
type Feat = {
  price_alerts: { buyers: number; adopters: number; adoption_pct: number; total_alerts: number; users_with_alerts: number; avg_per_active_user: number; triggered_rate_pct: number };
  features: { event: string; label: string; dau: number; mau: number; health: string }[];
};

const PERIODS = [{ v: 'day', l: 'День' }, { v: 'week', l: 'Неделя' }, { v: 'month', l: 'Месяц' }];

export default function SignalsBiPage() {
  const [period, setPeriod] = useState('week');
  const [rev, setRev] = useState<Rev | null>(null);
  const [deep, setDeep] = useState<Deep | null>(null);
  const [feat, setFeat] = useState<Feat | null>(null);
  const [err, setErr] = useState('');

  useEffect(() => {
    api<Rev>(`/admin/bi/revenue-compare?period=${period}`).then(setRev).catch((e) => setErr(e.message));
  }, [period]);
  useEffect(() => {
    api<Deep>('/admin/bi/signals-deep').then(setDeep).catch((e) => setErr(e.message));
    api<Feat>('/admin/bi/feature-adoption').then(setFeat).catch((e) => setErr(e.message));
  }, []);

  const tg = (v?: number) => `${Number(v ?? 0).toLocaleString('ru-RU')} ₸`;
  const n = (v?: number) => Number(v ?? 0).toLocaleString('ru-RU');
  const sigWins = rev?.winner === 'signals';

  return (
    <div>
      <h1>💎 Pay-per-Signal · фокус-модель</h1>
      <p className="muted">Разовые покупки сигналов за бонусы (1 бонус = 1 ₸). Главная ставка бизнеса — детальная аналитика ниже.</p>
      {err && <div className="err">{err}</div>}

      {/* ── Сравнение моделей ── */}
      <div className="row" style={{ gap: 8, margin: '14px 0' }}>
        {PERIODS.map((p) => (
          <button key={p.v} className={period === p.v ? '' : 'ghost'} style={{ padding: '6px 14px', fontSize: 13 }} onClick={() => setPeriod(p.v)}>{p.l}</button>
        ))}
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
        <div className="card" style={{ borderTop: `3px solid ${sigWins ? '#2563EB' : '#059669'}` }}>
          <div className="muted" style={{ fontSize: 12 }}>💎 Разовые сигналы {sigWins && <Badge text="лидер" color="#2563EB" />}</div>
          <div style={{ fontSize: 30, fontWeight: 800, color: '#2563EB' }}>{tg(rev?.signals.revenue)}</div>
          <div className="muted" style={{ fontSize: 12, marginTop: 4 }}>
            ARPU <b style={{ color: 'var(--text)' }}>{tg(rev?.signals.arpu)}</b> · {n(rev?.signals.purchases)} покупок · {n(rev?.signals.buyers)} покупателей
          </div>
        </div>
        <div className="card" style={{ borderTop: `3px solid ${!sigWins ? '#059669' : 'var(--border)'}` }}>
          <div className="muted" style={{ fontSize: 12 }}>💳 Подписки {rev?.winner === 'subscription' && <Badge text="лидер" color="#059669" />}</div>
          <div style={{ fontSize: 30, fontWeight: 800, color: '#059669' }}>{tg(rev?.subscription.revenue)}</div>
          <div className="muted" style={{ fontSize: 12, marginTop: 4 }}>
            ARPU <b style={{ color: 'var(--text)' }}>{tg(rev?.subscription.arpu)}</b> · {n(rev?.subscription.payers)} подписчиков
          </div>
        </div>
      </div>
      <div className="card" style={{ marginTop: 14 }}>
        <div className="muted" style={{ fontSize: 12, marginBottom: 8 }}>Динамика дохода: сигналы vs подписки</div>
        <LineChart
          labels={(rev?.series ?? []).map((s) => s.label)}
          series={[
            { name: 'Сигналы', color: '#2563EB', points: (rev?.series ?? []).map((s) => s.sig) },
            { name: 'Подписки', color: '#059669', points: (rev?.series ?? []).map((s) => s.sub) },
          ]}
        />
      </div>

      {/* ── Анализ ценности 500 vs 1000 ── */}
      <h2 style={{ marginTop: 28 }}>💰 Анализ ценности (500 vs 1000 бонусов)</h2>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
        <TierCard title="Тир 500 ₸" tier={deep?.value_tiers.t500} color="#0EA5E9" />
        <TierCard title="Тир 1000 ₸" tier={deep?.value_tiers.t1000} color="#7C3AED" />
      </div>

      {/* ── Whales ── */}
      <h2 style={{ marginTop: 28 }}>🐋 Топ-плательщики (Whales)</h2>
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <table style={tbl}>
          <thead><tr style={trh}><th style={td}>Пользователь</th><th style={td}>Потрачено</th><th style={td}>Сигналов</th><th style={td}>Последняя покупка</th></tr></thead>
          <tbody>
            {(deep?.whales ?? []).length === 0 && <tr><td colSpan={4} style={empty}>Покупок ещё нет</td></tr>}
            {(deep?.whales ?? []).map((w, i) => (
              <tr key={w.user_id} style={tr}>
                <td style={td}>{i < 3 ? ['🥇', '🥈', '🥉'][i] : `${i + 1}.`} {w.name}</td>
                <td style={{ ...td, fontWeight: 800, color: '#2563EB' }}>{tg(w.spent)}</td>
                <td style={td}>{n(w.signals_bought)}</td>
                <td style={{ ...td, color: 'var(--muted)' }}>{w.last_buy ? new Date(w.last_buy).toLocaleDateString('ru-RU') : '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* ── Топ-трейдеры по продажам ── */}
      <h2 style={{ marginTop: 28 }}>🏆 Топ-трейдеры по продажам (конверсия просмотр → покупка)</h2>
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <table style={tbl}>
          <thead><tr style={trh}><th style={td}>Трейдер</th><th style={td}>Выручка</th><th style={td}>Покупок</th><th style={td}>Покупателей</th><th style={td}>Просмотров</th><th style={td}>Конверсия</th><th style={td}>Win-rate</th></tr></thead>
          <tbody>
            {(deep?.top_traders ?? []).length === 0 && <tr><td colSpan={7} style={empty}>Данных пока нет</td></tr>}
            {(deep?.top_traders ?? []).map((t) => (
              <tr key={t.id} style={tr}>
                <td style={{ ...td, fontWeight: 600 }}>{t.name}</td>
                <td style={{ ...td, fontWeight: 700, color: '#2563EB' }}>{tg(t.revenue)}</td>
                <td style={td}>{n(t.purchases)}</td>
                <td style={td}>{n(t.buyers)}</td>
                <td style={td}>{n(t.viewers)}</td>
                <td style={{ ...td, fontWeight: 700, color: t.conversion_pct == null ? 'var(--muted)' : t.conversion_pct >= 30 ? '#059669' : '#D97706' }}>
                  {t.conversion_pct == null ? '—' : `${t.conversion_pct}%`}
                </td>
                <td style={td}>{Math.round((t.win_rate ?? 0) * 100)}%</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* ── Будильник цены ── */}
      <h2 style={{ marginTop: 28 }}>⏰ Будильник цены (Feature adoption)</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
        <Card label="Adoption" value={`${feat?.price_alerts.adoption_pct ?? 0}%`} hint={`${n(feat?.price_alerts.adopters)} из ${n(feat?.price_alerts.buyers)} покупателей`} color="#059669" big />
        <Card label="Будильников / юзер" value={String(feat?.price_alerts.avg_per_active_user ?? 0)} hint="среди активных" />
        <Card label="Сработали" value={`${feat?.price_alerts.triggered_rate_pct ?? 0}%`} hint={`всего ${n(feat?.price_alerts.total_alerts)}`} color="#D97706" />
        <Card label="Юзеров с будильником" value={n(feat?.price_alerts.users_with_alerts)} />
      </div>

      {/* ── Feature audit DAU/MAU ── */}
      <h2 style={{ marginTop: 28 }}>📊 Использование разделов (DAU / MAU)</h2>
      <p className="muted" style={{ fontSize: 12, marginBottom: 8 }}>«Мёртвые» фичи (MAU &lt; 5% от общего) подсвечены — кандидаты на улучшение или удаление.</p>
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <table style={tbl}>
          <thead><tr style={trh}><th style={td}>Раздел</th><th style={td}>DAU</th><th style={td}>MAU</th><th style={td}>Статус</th></tr></thead>
          <tbody>
            {(feat?.features ?? []).length === 0 && <tr><td colSpan={4} style={empty}>Данные появятся после накопления активности</td></tr>}
            {(feat?.features ?? []).map((f) => (
              <tr key={f.event} style={tr}>
                <td style={{ ...td, fontWeight: 600 }}>{f.label}</td>
                <td style={td}>{n(f.dau)}</td>
                <td style={td}>{n(f.mau)}</td>
                <td style={td}>{f.health === 'low'
                  ? <span style={{ color: '#DC2626', fontWeight: 700, fontSize: 12 }}>🔴 мало</span>
                  : <span style={{ color: '#059669', fontSize: 12 }}>🟢 ок</span>}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

const tbl: React.CSSProperties = { width: '100%', borderCollapse: 'collapse', fontSize: 13 };
const trh: React.CSSProperties = { textAlign: 'left', color: 'var(--muted)' };
const tr: React.CSSProperties = { borderTop: '1px solid var(--border)' };
const td: React.CSSProperties = { padding: '9px 14px' };
const empty: React.CSSProperties = { padding: 16, color: 'var(--muted)' };

function Badge({ text, color }: { text: string; color: string }) {
  return <span style={{ fontSize: 11, fontWeight: 700, color, background: `${color}1a`, padding: '2px 8px', borderRadius: 20, marginLeft: 6 }}>{text}</span>;
}
function Card({ label, value, hint, color, big }: { label: string; value: string; hint?: string; color?: string; big?: boolean }) {
  return (
    <div className="card">
      <div className="muted" style={{ fontSize: 12 }}>{label}</div>
      <div style={{ fontSize: big ? 28 : 22, fontWeight: 800, color: color ?? 'var(--text)' }}>{value}</div>
      {hint && <div className="muted" style={{ fontSize: 11, marginTop: 2 }}>{hint}</div>}
    </div>
  );
}
function TierCard({ title, tier, color }: { title: string; tier?: Tier; color: string }) {
  const tg = (v?: number) => `${Number(v ?? 0).toLocaleString('ru-RU')} ₸`;
  const n = (v?: number) => Number(v ?? 0).toLocaleString('ru-RU');
  return (
    <div className="card" style={{ borderLeft: `4px solid ${color}` }}>
      <div className="muted" style={{ fontSize: 12 }}>{title}</div>
      <div style={{ fontSize: 26, fontWeight: 800, color }}>{tg(tier?.revenue)}</div>
      <div className="muted" style={{ fontSize: 12, marginTop: 4 }}>{n(tier?.purchases)} покупок · {n(tier?.buyers)} покупателей</div>
    </div>
  );
}
