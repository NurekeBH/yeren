'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Stats = {
  users: string; blocked: string; traders: string; admins: string;
  new_7d: string; providers: string; signals: string; events: string;
  idea_sales: string; bonus_outstanding: string;
  topup_total: string; topup_count: string; topup_7d: string; bonus_issued: string;
  course_sales: string; course_bonus: string; signal_bonus: string;
  exams_taken: string; exams_passed: string;
};

type Tx = {
  id: string; type: string; amount: number; ref: string | null;
  created_at: string; phone: string; name: string | null;
};

export default function Overview() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [txs, setTxs] = useState<Tx[]>([]);
  const [pending, setPending] = useState(0);
  const [apps, setApps] = useState(0);
  const [err, setErr] = useState('');

  useEffect(() => {
    (async () => {
      try {
        const [s, sub, ta, tx] = await Promise.all([
          api<{ stats: Stats }>('/admin/stats').then((r) => r.stats),
          api<{ items: any[] }>('/subscription/pending').then((r) => r.items.length).catch(() => 0),
          api<{ applications: any[] }>('/admin/trader-applications?status=pending').then((r) => r.applications.length).catch(() => 0),
          api<{ transactions: Tx[] }>('/admin/bonus/transactions?limit=40').then((r) => r.transactions).catch(() => []),
        ]);
        setStats(s);
        setPending(sub);
        setApps(ta);
        setTxs(tx);
      } catch (e: any) {
        setErr(e.message);
      }
    })();
  }, []);

  const n = (v?: string) => Number(v ?? 0).toLocaleString('ru-RU');
  const tg = (v?: string) => `${Number(v ?? 0).toLocaleString('ru-RU')} ₸`;

  const overview: { label: string; value: string; accent?: boolean }[] = [
    { label: 'Пользователи', value: n(stats?.users), accent: true },
    { label: 'Новые за 7 дней', value: n(stats?.new_7d) },
    { label: 'Трейдеры', value: n(stats?.traders) },
    { label: 'Заблокированы', value: n(stats?.blocked) },
    { label: 'Заявки трейдеров', value: String(apps) },
    { label: 'Провайдеры', value: n(stats?.providers) },
    { label: 'Сигналы / Идеи', value: n(stats?.signals) },
    { label: 'События', value: n(stats?.events) },
    { label: 'Подписки на проверке', value: String(pending) },
    { label: 'Админы', value: n(stats?.admins) },
  ];

  // 💰 Монетизация: бонус = ₸ (1:1). Пополнения = реальная выручка через Kaspi.
  const money: { label: string; value: string; hint?: string; accent?: boolean }[] = [
    { label: 'Выручка (пополнения)', value: tg(stats?.topup_total), hint: 'Kaspi, всего', accent: true },
    { label: 'Выручка за 7 дней', value: tg(stats?.topup_7d), hint: 'Kaspi' },
    { label: 'Пополнений', value: n(stats?.topup_count), hint: 'транзакций' },
    { label: 'Продажи курсов', value: n(stats?.course_sales), hint: `${tg(stats?.course_bonus)} бонусов` },
    { label: 'Продажи идей', value: n(stats?.idea_sales), hint: `${tg(stats?.signal_bonus)} бонусов` },
    { label: 'Бонусов в обороте', value: n(stats?.bonus_outstanding), hint: 'на балансах' },
    { label: 'Бонусов выдано', value: n(stats?.bonus_issued), hint: 'рефералка (расход)' },
    { label: 'Экзамены', value: `${n(stats?.exams_passed)} / ${n(stats?.exams_taken)}`, hint: 'сдано / пройдено' },
  ];

  const txLabel: Record<string, string> = {
    topup: '💳 Пополнение',
    spend_course: '🎓 Курс',
    spend_signal: '📈 Идея',
    referral: '🎁 Реферал',
    signup: '✨ Регистрация',
  };

  return (
    <div>
      <h1>Обзор</h1>
      {err && <div className="err">{err}</div>}

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14, marginTop: 12 }}>
        {overview.map((c) => (
          <div className="card" key={c.label}>
            <div className="muted" style={{ fontSize: 12 }}>{c.label}</div>
            <div style={{ fontSize: 30, fontWeight: 800, color: c.accent ? 'var(--gold)' : 'var(--text)' }}>{c.value}</div>
          </div>
        ))}
      </div>

      <h2 style={{ marginTop: 32 }}>💰 Монетизация</h2>
      <div className="muted" style={{ fontSize: 12, marginBottom: 10 }}>
        1 бонус = 1 ₸. Пополнения через Kaspi — это реальная выручка.
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
        {money.map((c) => (
          <div className="card" key={c.label}>
            <div className="muted" style={{ fontSize: 12 }}>{c.label}</div>
            <div style={{ fontSize: 26, fontWeight: 800, color: c.accent ? 'var(--gold)' : 'var(--text)' }}>{c.value}</div>
            {c.hint && <div className="muted" style={{ fontSize: 11, marginTop: 2 }}>{c.hint}</div>}
          </div>
        ))}
      </div>

      <h2 style={{ marginTop: 32 }}>Последние операции с бонусами</h2>
      <div className="card" style={{ marginTop: 10, padding: 0, overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead>
            <tr style={{ textAlign: 'left', color: 'var(--muted)' }}>
              <th style={{ padding: '10px 14px' }}>Тип</th>
              <th style={{ padding: '10px 14px' }}>Пользователь</th>
              <th style={{ padding: '10px 14px' }}>Сумма</th>
              <th style={{ padding: '10px 14px' }}>Ссылка</th>
              <th style={{ padding: '10px 14px' }}>Дата</th>
            </tr>
          </thead>
          <tbody>
            {txs.length === 0 && (
              <tr><td colSpan={5} style={{ padding: 16, color: 'var(--muted)' }}>Пока нет операций</td></tr>
            )}
            {txs.map((t) => (
              <tr key={t.id} style={{ borderTop: '1px solid var(--border)' }}>
                <td style={{ padding: '10px 14px' }}>{txLabel[t.type] ?? t.type}</td>
                <td style={{ padding: '10px 14px' }}>{t.name || t.phone}</td>
                <td style={{ padding: '10px 14px', fontWeight: 700, color: t.amount >= 0 ? 'var(--green, #059669)' : 'var(--red, #DC2626)' }}>
                  {t.amount >= 0 ? '+' : ''}{t.amount.toLocaleString('ru-RU')}
                </td>
                <td style={{ padding: '10px 14px', color: 'var(--muted)' }}>{t.ref ?? '—'}</td>
                <td style={{ padding: '10px 14px', color: 'var(--muted)' }}>
                  {new Date(t.created_at).toLocaleString('ru-RU', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
