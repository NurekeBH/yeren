'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Stats = {
  users: string; blocked: string; traders: string; admins: string;
  new_7d: string; providers: string; signals: string; events: string;
  idea_sales: string; bonus_outstanding: string;
};

export default function Overview() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [pending, setPending] = useState(0);
  const [apps, setApps] = useState(0);
  const [err, setErr] = useState('');

  useEffect(() => {
    (async () => {
      try {
        const [s, sub, ta] = await Promise.all([
          api<{ stats: Stats }>('/admin/stats').then((r) => r.stats),
          api<{ items: any[] }>('/subscription/pending').then((r) => r.items.length).catch(() => 0),
          api<{ applications: any[] }>('/admin/trader-applications?status=pending').then((r) => r.applications.length).catch(() => 0),
        ]);
        setStats(s);
        setPending(sub);
        setApps(ta);
      } catch (e: any) {
        setErr(e.message);
      }
    })();
  }, []);

  const n = (v?: string) => Number(v ?? 0).toLocaleString('ru-RU');
  const cards: { label: string; value: string; accent?: boolean }[] = [
    { label: 'Пользователи', value: n(stats?.users), accent: true },
    { label: 'Новые за 7 дней', value: n(stats?.new_7d) },
    { label: 'Трейдеры', value: n(stats?.traders) },
    { label: 'Заблокированы', value: n(stats?.blocked) },
    { label: 'Заявки трейдеров', value: String(apps) },
    { label: 'Провайдеры', value: n(stats?.providers) },
    { label: 'Сигналы / Идеи', value: n(stats?.signals) },
    { label: 'События', value: n(stats?.events) },
    { label: 'Продажи идей', value: n(stats?.idea_sales) },
    { label: 'Бонусов в обороте', value: n(stats?.bonus_outstanding) },
    { label: 'Подписки на проверке', value: String(pending) },
    { label: 'Админы', value: n(stats?.admins) },
  ];

  return (
    <div>
      <h1>Обзор</h1>
      {err && <div className="err">{err}</div>}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14, marginTop: 12 }}>
        {cards.map((c) => (
          <div className="card" key={c.label}>
            <div className="muted" style={{ fontSize: 12 }}>{c.label}</div>
            <div style={{ fontSize: 30, fontWeight: 800, color: c.accent ? 'var(--gold)' : 'var(--text)' }}>{c.value}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
