'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { api } from '@/lib/api';

type Stats = {
  users: string; blocked: string; traders: string; admins: string;
  new_7d: string; providers: string; signals: string; events: string;
  topup_total: string; bonus_outstanding: string;
};

type CountryRow = { country: string; count: number; pct: number };

// ISO-2 → ту + аты (танысы; әйтпесе кодты көрсетеміз).
const COUNTRY: Record<string, { flag: string; name: string }> = {
  KZ: { flag: '🇰🇿', name: 'Казахстан' }, RU: { flag: '🇷🇺', name: 'Россия' },
  UZ: { flag: '🇺🇿', name: 'Узбекистан' }, KG: { flag: '🇰🇬', name: 'Кыргызстан' },
  TJ: { flag: '🇹🇯', name: 'Таджикистан' }, TM: { flag: '🇹🇲', name: 'Туркменистан' },
  AZ: { flag: '🇦🇿', name: 'Азербайджан' }, GE: { flag: '🇬🇪', name: 'Грузия' },
  AM: { flag: '🇦🇲', name: 'Армения' }, BY: { flag: '🇧🇾', name: 'Беларусь' },
  UA: { flag: '🇺🇦', name: 'Украина' }, MD: { flag: '🇲🇩', name: 'Молдова' },
  TR: { flag: '🇹🇷', name: 'Турция' }, AE: { flag: '🇦🇪', name: 'ОАЭ' },
  CN: { flag: '🇨🇳', name: 'Китай' }, DE: { flag: '🇩🇪', name: 'Германия' },
  GB: { flag: '🇬🇧', name: 'Великобритания' }, US: { flag: '🇺🇸', name: 'США' },
  unknown: { flag: '🌐', name: 'Не указана' },
};

export default function Overview() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [countries, setCountries] = useState<CountryRow[]>([]);
  const [pending, setPending] = useState(0);
  const [apps, setApps] = useState(0);
  const [err, setErr] = useState('');

  useEffect(() => {
    (async () => {
      try {
        const [s, sub, ta, geo] = await Promise.all([
          api<{ stats: Stats }>('/admin/stats').then((r) => r.stats),
          api<{ items: any[] }>('/subscription/pending').then((r) => r.items.length).catch(() => 0),
          api<{ applications: any[] }>('/admin/trader-applications?status=pending').then((r) => r.applications.length).catch(() => 0),
          api<{ countries: CountryRow[] }>('/admin/stats/countries').then((r) => r.countries).catch(() => []),
        ]);
        setStats(s);
        setPending(sub);
        setApps(ta);
        setCountries(geo);
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
    { label: 'Заявки провайдеров', value: String(apps) },
    { label: 'Провайдеры', value: n(stats?.providers) },
    { label: 'Сигналы / Идеи', value: n(stats?.signals) },
    { label: 'События', value: n(stats?.events) },
    { label: 'Подписки на проверке', value: String(pending) },
    { label: 'Админы', value: n(stats?.admins) },
  ];

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

      {/* Қаржы қысқаша — толығы «Финансы» табында */}
      <div className="card" style={{ marginTop: 16, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <div className="muted" style={{ fontSize: 12 }}>💰 Выручка (пополнения Kaspi)</div>
          <div style={{ fontSize: 26, fontWeight: 800, color: '#059669' }}>{tg(stats?.topup_total)}</div>
          <div className="muted" style={{ fontSize: 11 }}>Бонусов на балансах: {tg(stats?.bonus_outstanding)}</div>
        </div>
        <Link href="/dashboard/finance" style={{ color: 'var(--accent)', fontWeight: 600 }}>
          Подробнее → Финансы
        </Link>
      </div>

      {/* 🌍 География — для решения о новых языках */}
      <h2 style={{ marginTop: 32 }}>🌍 География пользователей</h2>
      <div className="muted" style={{ fontSize: 12, marginBottom: 10 }}>
        По стране, выбранной при регистрации. Помогает решить, какой язык добавить следующим.
      </div>
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead>
            <tr style={{ textAlign: 'left', color: 'var(--muted)' }}>
              <th style={{ padding: '10px 14px' }}>Страна</th>
              <th style={{ padding: '10px 14px' }}>Пользователей</th>
              <th style={{ padding: '10px 14px', width: '45%' }}>Доля</th>
            </tr>
          </thead>
          <tbody>
            {countries.length === 0 && (
              <tr><td colSpan={3} style={{ padding: 16, color: 'var(--muted)' }}>Нет данных</td></tr>
            )}
            {countries.map((c) => {
              const meta = COUNTRY[c.country] ?? { flag: '🏳️', name: c.country };
              return (
                <tr key={c.country} style={{ borderTop: '1px solid var(--border)' }}>
                  <td style={{ padding: '10px 14px' }}>{meta.flag} {meta.name}</td>
                  <td style={{ padding: '10px 14px', fontWeight: 700 }}>{c.count.toLocaleString('ru-RU')}</td>
                  <td style={{ padding: '10px 14px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                      <div style={{ flex: 1, height: 8, background: 'var(--border)', borderRadius: 4, overflow: 'hidden' }}>
                        <div style={{ width: `${c.pct}%`, height: '100%', background: 'var(--gold)' }} />
                      </div>
                      <span className="muted" style={{ minWidth: 38, textAlign: 'right' }}>{c.pct}%</span>
                    </div>
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
