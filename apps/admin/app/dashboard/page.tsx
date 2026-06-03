'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

export default function Overview() {
  const [stats, setStats] = useState<{ pending: number; providers: number; events: number; signals: number }>({
    pending: 0,
    providers: 0,
    events: 0,
    signals: 0,
  });
  const [err, setErr] = useState('');

  useEffect(() => {
    (async () => {
      try {
        const [pending, providers, events, signals] = await Promise.all([
          api<{ items: any[] }>('/subscription/pending').then((r) => r.items.length).catch(() => 0),
          api<{ providers: any[] }>('/providers').then((r) => r.providers.length).catch(() => 0),
          api<{ events: any[] }>('/events').then((r) => r.events.length).catch(() => 0),
          api<{ signals: any[] }>('/signals').then((r) => r.signals.length).catch(() => 0),
        ]);
        setStats({ pending, providers, events, signals });
      } catch (e: any) {
        setErr(e.message);
      }
    })();
  }, []);

  const cards = [
    { label: 'Подписки на проверке', value: stats.pending },
    { label: 'Провайдеры', value: stats.providers },
    { label: 'События', value: stats.events },
    { label: 'Сигналы / Идеи', value: stats.signals },
  ];

  return (
    <div>
      <h1>Обзор</h1>
      {err && <div className="err">{err}</div>}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 14 }}>
        {cards.map((c) => (
          <div className="card" key={c.label}>
            <div className="muted" style={{ fontSize: 12 }}>{c.label}</div>
            <div style={{ fontSize: 32, fontWeight: 800, color: 'var(--gold)' }}>{c.value}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
