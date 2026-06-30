'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { api } from '@/lib/api';
import { LineChart, CohortHeatmap } from '@/components/charts';

type Stats = {
  users: string; blocked: string; traders: string; admins: string;
  new_7d: string; providers: string; signals: string; events: string;
};
type Ov = {
  dau: number; mau: number; stickiness_pct: number; mrr: number; arr: number;
  net_margin_pct: number; ltv_cac: number; churn_pct: number; paying_users: number;
};
type Insight = {
  id: string; severity: string; title: string; body: string;
  action: string | null; action_kind: string | null;
};
type GeoRow = { key: string; count: number; pct: number };
type Geo = { countries: GeoRow[]; cities: GeoRow[]; locales: GeoRow[] };
type Content = {
  courses: { id: string; title: string; views: number; buyers: number; cvr_pct: number }[];
  providers: { id: string; name: string; subscribers: number; retention_pct: number; lost_30d: number }[];
  ideas: { id: string; pair: string; direction: string; paid_opens: number; voters: number }[];
};
type Cohorts = { cohorts: { cohort: string; size: number; weeks: Record<number, number> }[] };
type Reg = { daily: { day: string; count: number }[]; today: number; yesterday: number };

const COUNTRY: Record<string, { flag: string; name: string }> = {
  KZ: { flag: '🇰🇿', name: 'Казахстан' }, RU: { flag: '🇷🇺', name: 'Россия' },
  UZ: { flag: '🇺🇿', name: 'Узбекистан' }, KG: { flag: '🇰🇬', name: 'Кыргызстан' },
  TJ: { flag: '🇹🇯', name: 'Таджикистан' }, TM: { flag: '🇹🇲', name: 'Туркменистан' },
  AZ: { flag: '🇦🇿', name: 'Азербайджан' }, GE: { flag: '🇬🇪', name: 'Грузия' },
  AM: { flag: '🇦🇲', name: 'Армения' }, BY: { flag: '🇧🇾', name: 'Беларусь' },
  UA: { flag: '🇺🇦', name: 'Украина' }, TR: { flag: '🇹🇷', name: 'Турция' },
  AE: { flag: '🇦🇪', name: 'ОАЭ' }, unknown: { flag: '🌐', name: 'Не указана' },
  '—': { flag: '🌐', name: 'Не указано' },
};
const LOCALE: Record<string, string> = { ru: '🇷🇺 Русский', kk: '🇰🇿 Қазақша', en: '🇬🇧 English' };
const SEV: Record<string, { bg: string; bd: string; icon: string }> = {
  critical: { bg: '#DC26261a', bd: '#DC2626', icon: '🔴' },
  warning: { bg: '#D979061a', bd: '#D97706', icon: '🟡' },
  opportunity: { bg: '#0596691a', bd: '#059669', icon: '🟢' },
  info: { bg: '#2563EB1a', bd: '#2563EB', icon: 'ℹ️' },
};

export default function Overview() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [ov, setOv] = useState<Ov | null>(null);
  const [insights, setInsights] = useState<Insight[]>([]);
  const [geo, setGeo] = useState<Geo | null>(null);
  const [content, setContent] = useState<Content | null>(null);
  const [cohorts, setCohorts] = useState<Cohorts['cohorts']>([]);
  const [reg, setReg] = useState<Reg | null>(null);
  const [pending, setPending] = useState(0);
  const [apps, setApps] = useState(0);
  const [err, setErr] = useState('');

  useEffect(() => {
    const swallow = <T,>(p: Promise<T>, fb: T) => p.catch(() => fb);
    (async () => {
      try {
        const [s, o, ins, g, c, co, r, sub, ta] = await Promise.all([
          api<{ stats: Stats }>('/admin/stats').then((x) => x.stats),
          api<Ov>('/admin/bi/overview'),
          swallow(api<{ insights: Insight[] }>('/admin/bi/insights').then((x) => x.insights), []),
          swallow(api<Geo>('/admin/bi/geo'), null as Geo | null),
          swallow(api<Content>('/admin/bi/content'), null as Content | null),
          swallow(api<Cohorts>('/admin/bi/cohorts').then((x) => x.cohorts), [] as Cohorts['cohorts']),
          swallow(api<Reg>('/admin/stats/registrations'), null as Reg | null),
          swallow(api<{ items: any[] }>('/subscription/pending').then((x) => x.items.length), 0),
          swallow(api<{ applications: any[] }>('/admin/trader-applications?status=pending').then((x) => x.applications.length), 0),
        ]);
        setStats(s); setOv(o); setInsights(ins); setGeo(g); setContent(c);
        setCohorts(co); setReg(r); setPending(sub); setApps(ta);
      } catch (e: any) {
        setErr(e.message);
      }
    })();
  }, []);

  const dismiss = async (id: string) => {
    setInsights((xs) => xs.filter((x) => x.id !== id));
    await api(`/admin/bi/insights/${id}/dismiss`, { method: 'POST' }).catch(() => {});
  };

  const n = (v?: string | number) => Number(v ?? 0).toLocaleString('ru-RU');
  const tg = (v?: number) => `${Number(v ?? 0).toLocaleString('ru-RU')} ₸`;
  const health = (r: number) => (r >= 3 ? '#059669' : r >= 1 ? '#D97706' : '#DC2626');

  return (
    <div>
      <h1>🎯 Командный пункт</h1>
      {err && <div className="err">{err}</div>}

      {/* ── KPI лента ── */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 12, marginTop: 12 }}>
        <Kpi label="DAU" value={n(ov?.dau)} hint={`MAU ${n(ov?.mau)}`} />
        <Kpi label="Stickiness" value={`${ov?.stickiness_pct ?? 0}%`} hint="норма > 20%" color={(ov?.stickiness_pct ?? 0) >= 20 ? '#059669' : '#D97706'} />
        <Kpi label="MRR" value={tg(ov?.mrr)} hint={`ARR ${tg(ov?.arr)}`} color="#059669" />
        <Kpi label="Маржа" value={`${ov?.net_margin_pct ?? 0}%`} hint="чистая, 30д" color={(ov?.net_margin_pct ?? 0) >= 0 ? '#059669' : '#DC2626'} />
        <Kpi label="LTV / CAC" value={`${ov?.ltv_cac ?? 0}×`} hint="норма > 3" color={health(ov?.ltv_cac ?? 0)} />
        <Kpi label="Churn" value={`${ov?.churn_pct ?? 0}%`} hint="подписки/мес" color={(ov?.churn_pct ?? 0) > 10 ? '#DC2626' : 'var(--text)'} />
      </div>

      {/* ── AI-подсказки ── */}
      <h2 style={{ marginTop: 28 }}>🤖 AI-подсказки</h2>
      {insights.length === 0 ? (
        <div className="card muted" style={{ fontSize: 13 }}>
          Пока нет подсказок. Они появляются автоматически при росте данных (всплески спроса, отток, аномалии LTV/CAC).
        </div>
      ) : (
        <div style={{ display: 'grid', gap: 10 }}>
          {insights.map((i) => {
            const sv = SEV[i.severity] ?? SEV.info;
            return (
              <div key={i.id} className="card" style={{ borderLeft: `4px solid ${sv.bd}`, background: sv.bg }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', gap: 12 }}>
                  <div>
                    <div style={{ fontWeight: 700, marginBottom: 4 }}>{sv.icon} {i.title}</div>
                    <div style={{ fontSize: 13 }}>{i.body}</div>
                    {i.action && <div style={{ fontSize: 13, marginTop: 6 }}>👉 <b>Действие:</b> {i.action}</div>}
                  </div>
                  <button className="ghost" style={{ padding: '4px 10px', fontSize: 12, height: 'fit-content' }} onClick={() => dismiss(i.id)}>Скрыть</button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* ── Регистрации (тренд) ── */}
      <div className="card" style={{ marginTop: 16 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
          <div className="muted" style={{ fontSize: 12 }}>Регистрации за 30 дней</div>
          <div className="muted" style={{ fontSize: 12 }}>Сегодня: <b style={{ color: 'var(--gold)' }}>{n(reg?.today)}</b> · вчера: {n(reg?.yesterday)}</div>
        </div>
        <LineChart
          labels={(reg?.daily ?? []).map((d) => d.day)}
          series={[{ name: 'Регистрации', color: '#2563EB', points: (reg?.daily ?? []).map((d) => d.count) }]}
        />
      </div>

      {/* ── База: счётчики ── */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12, marginTop: 16 }}>
        <Mini label="Пользователи" value={n(stats?.users)} accent />
        <Mini label="Новые за 7д" value={n(stats?.new_7d)} />
        <Mini label="Платящие" value={n(ov?.paying_users)} />
        <Mini label="Провайдеры" value={n(stats?.providers)} />
        <Mini label="Заявки провайдеров" value={String(apps)} />
        <Mini label="Подписки на проверке" value={String(pending)} />
        <Mini label="Сигналы / Идеи" value={n(stats?.signals)} />
        <Mini label="События" value={n(stats?.events)} />
      </div>

      {/* ── Гео + язык ── */}
      <h2 style={{ marginTop: 32 }}>🌍 География и язык</h2>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
        <GeoCard title="Топ городов (таргет)" rows={geo?.cities ?? []} render={(k) => k} />
        <GeoCard title="Страны" rows={geo?.countries ?? []} render={(k) => `${(COUNTRY[k] ?? { flag: '🏳️' }).flag} ${(COUNTRY[k] ?? { name: k }).name}`} />
      </div>
      <div className="card" style={{ marginTop: 14 }}>
        <div className="muted" style={{ fontSize: 12, marginBottom: 8 }}>Язык интерфейса</div>
        <div style={{ display: 'flex', gap: 20, flexWrap: 'wrap' }}>
          {(geo?.locales ?? []).map((l) => (
            <div key={l.key}><b style={{ fontSize: 18 }}>{l.pct}%</b> <span className="muted">{LOCALE[l.key] ?? l.key} ({n(l.count)})</span></div>
          ))}
        </div>
      </div>

      {/* ── Контент: конверсия и рейтинги ── */}
      <h2 style={{ marginTop: 32 }}>📈 Контент и провайдеры</h2>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          <Caption>Конверсия курсов (просмотр → покупка)</Caption>
          <Tbl head={['Курс', 'Просм.', 'Купили', 'CVR']} rows={(content?.courses ?? []).slice(0, 8).map((c) => [c.title, n(c.views), n(c.buyers), `${c.cvr_pct}%`])} />
        </div>
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          <Caption>Провайдеры: подписчики и удержание</Caption>
          <Tbl head={['Провайдер', 'Подп.', 'Отток30', 'Retention']} rows={(content?.providers ?? []).slice(0, 8).map((p) => [p.name, n(p.subscribers), n(p.lost_30d), `${p.retention_pct}%`])} />
        </div>
      </div>
      <div className="card" style={{ padding: 0, overflow: 'hidden', marginTop: 14 }}>
        <Caption>Самые открываемые идеи</Caption>
        <Tbl head={['Пара', 'Направление', 'Платных открытий', 'Голосов']} rows={(content?.ideas ?? []).slice(0, 8).map((i) => [i.pair, i.direction, n(i.paid_opens), n(i.voters)])} />
      </div>

      {/* ── Когортный анализ ── */}
      <h2 style={{ marginTop: 32 }}>🔥 Когортный анализ (удержание по неделям регистрации)</h2>
      <div className="card">
        <CohortHeatmap rows={cohorts} />
      </div>

      <div className="card" style={{ marginTop: 16, display: 'flex', justifyContent: 'flex-end' }}>
        <Link href="/dashboard/finance" style={{ color: 'var(--accent)', fontWeight: 600 }}>Подробный P&L → Финансы</Link>
      </div>
    </div>
  );
}

function Kpi({ label, value, hint, color }: { label: string; value: string; hint?: string; color?: string }) {
  return (
    <div className="card" style={{ padding: '12px 14px' }}>
      <div className="muted" style={{ fontSize: 11 }}>{label}</div>
      <div style={{ fontSize: 22, fontWeight: 800, color: color ?? 'var(--text)' }}>{value}</div>
      {hint && <div className="muted" style={{ fontSize: 10, marginTop: 1 }}>{hint}</div>}
    </div>
  );
}
function Mini({ label, value, accent }: { label: string; value: string; accent?: boolean }) {
  return (
    <div className="card" style={{ padding: '10px 14px' }}>
      <div className="muted" style={{ fontSize: 12 }}>{label}</div>
      <div style={{ fontSize: 24, fontWeight: 800, color: accent ? 'var(--gold)' : 'var(--text)' }}>{value}</div>
    </div>
  );
}
function GeoCard({ title, rows, render }: { title: string; rows: GeoRow[]; render: (k: string) => string }) {
  return (
    <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
      <Caption>{title}</Caption>
      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
        <tbody>
          {rows.length === 0 && <tr><td style={{ padding: 14, color: 'var(--muted)' }}>Нет данных</td></tr>}
          {rows.slice(0, 10).map((r) => (
            <tr key={r.key} style={{ borderTop: '1px solid var(--border)' }}>
              <td style={{ padding: '8px 14px' }}>{render(r.key)}</td>
              <td style={{ padding: '8px 14px', fontWeight: 700, width: 60 }}>{r.count.toLocaleString('ru-RU')}</td>
              <td style={{ padding: '8px 14px', width: '45%' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <div style={{ flex: 1, height: 7, background: 'var(--border)', borderRadius: 4, overflow: 'hidden' }}>
                    <div style={{ width: `${r.pct}%`, height: '100%', background: 'var(--gold)' }} />
                  </div>
                  <span className="muted" style={{ minWidth: 34, textAlign: 'right', fontSize: 12 }}>{r.pct}%</span>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
function Caption({ children }: { children: React.ReactNode }) {
  return <div className="muted" style={{ fontSize: 12, padding: '10px 14px', borderBottom: '1px solid var(--border)' }}>{children}</div>;
}
function Tbl({ head, rows }: { head: string[]; rows: (string | number)[][] }) {
  return (
    <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
      <thead>
        <tr style={{ textAlign: 'left', color: 'var(--muted)' }}>
          {head.map((h, i) => <th key={i} style={{ padding: '8px 14px', fontWeight: 600 }}>{h}</th>)}
        </tr>
      </thead>
      <tbody>
        {rows.length === 0 && <tr><td colSpan={head.length} style={{ padding: 14, color: 'var(--muted)' }}>Нет данных</td></tr>}
        {rows.map((r, ri) => (
          <tr key={ri} style={{ borderTop: '1px solid var(--border)' }}>
            {r.map((c, ci) => <td key={ci} style={{ padding: '8px 14px', fontWeight: ci === 0 ? 600 : 400 }}>{c}</td>)}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
