'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type User = {
  id: string;
  phone: string;
  name: string;
  city: string;
  country: string | null;
  is_admin: boolean;
  is_verified_trader: boolean;
  is_blocked: boolean;
  promo_code: string | null;
  bonus_balance: number;
  referral_count: number;
  created_at: string;
};

type Stats = { users: string; new_7d: string; traders: string; blocked: string };
type CountryRow = { country: string; count: number; pct: number };
type Reg = {
  today: number; yesterday: number; last_7d: number; last_30d: number; total: number;
  daily: { day: string; count: number }[];
};

// ISO-2 → ту + аты (тіркеуде таңдалған ел).
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
const cMeta = (c?: string | null) => COUNTRY[c || 'unknown'] ?? { flag: '🏳️', name: c };
const fmtDate = (iso: string) => {
  const d = new Date(iso);
  return Number.isNaN(d.getTime()) ? '—' : d.toLocaleDateString('ru-RU', { day: '2-digit', month: '2-digit', year: 'numeric' });
};

export default function UsersPage() {
  const [items, setItems] = useState<User[]>([]);
  const [stats, setStats] = useState<Stats | null>(null);
  const [countries, setCountries] = useState<CountryRow[]>([]);
  const [reg, setReg] = useState<Reg | null>(null);
  const [search, setSearch] = useState('');
  const [err, setErr] = useState('');
  const [busyId, setBusyId] = useState('');

  async function load() {
    try {
      const r = await api<{ users: User[] }>(`/admin/users${search ? `?search=${encodeURIComponent(search)}` : ''}`);
      setItems(r.users);
    } catch (e: any) {
      setErr(e.message);
    }
  }
  async function loadStats() {
    const [s, geo, rg] = await Promise.all([
      api<{ stats: Stats }>('/admin/stats').then((r) => r.stats).catch(() => null),
      api<{ countries: CountryRow[] }>('/admin/stats/countries').then((r) => r.countries).catch(() => []),
      api<Reg>('/admin/stats/registrations').catch(() => null),
    ]);
    setStats(s);
    setCountries(geo);
    setReg(rg);
  }
  useEffect(() => {
    load();
    loadStats();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function toggleBlock(u: User) {
    setBusyId(u.id);
    setErr('');
    try {
      await api(`/admin/users/${u.id}/block`, { method: 'POST', body: { blocked: !u.is_blocked } });
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusyId('');
    }
  }

  async function setRole(u: User, patch: { is_admin?: boolean; is_verified_trader?: boolean }) {
    setBusyId(u.id);
    setErr('');
    try {
      await api(`/admin/users/${u.id}/role`, { method: 'PATCH', body: patch });
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusyId('');
    }
  }

  const n = (v?: string) => Number(v ?? 0).toLocaleString('ru-RU');
  const topCountries = countries.filter((c) => c.country !== 'unknown').slice(0, 6);

  return (
    <div>
      <h1>Пользователи</h1>
      {err && <div className="err">{err}</div>}

      {/* Зарегистрировано — счётчики */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12, margin: '12px 0' }}>
        {[
          { label: 'Всего зарегистрировано', value: n(stats?.users), accent: true },
          { label: 'Новые за 7 дней', value: n(stats?.new_7d) },
          { label: 'Провайдеры', value: n(stats?.traders) },
          { label: 'Заблокированы', value: n(stats?.blocked) },
        ].map((c) => (
          <div className="card" key={c.label}>
            <div className="muted" style={{ fontSize: 12 }}>{c.label}</div>
            <div style={{ fontSize: 26, fontWeight: 800, color: c.accent ? 'var(--gold)' : 'var(--text)' }}>{c.value}</div>
          </div>
        ))}
      </div>

      {/* 📈 Регистрации — производительность по дням (маркетинг/аналитика) */}
      {reg && (
        <div className="card" style={{ margin: '0 0 16px' }}>
          <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap', marginBottom: 14 }}>
            <div>
              <div className="muted" style={{ fontSize: 12 }}>Сегодня</div>
              <div style={{ fontSize: 28, fontWeight: 800, color: 'var(--gold)' }}>
                +{reg.today.toLocaleString('ru-RU')}
                {reg.yesterday > 0 && (
                  <span style={{ fontSize: 13, fontWeight: 600, marginLeft: 8, color: reg.today >= reg.yesterday ? '#059669' : '#dc2626' }}>
                    {reg.today >= reg.yesterday ? '▲' : '▼'} {Math.round(((reg.today - reg.yesterday) / reg.yesterday) * 100)}%
                  </span>
                )}
              </div>
            </div>
            <div>
              <div className="muted" style={{ fontSize: 12 }}>Вчера</div>
              <div style={{ fontSize: 28, fontWeight: 800 }}>+{reg.yesterday.toLocaleString('ru-RU')}</div>
            </div>
            <div>
              <div className="muted" style={{ fontSize: 12 }}>За 7 дней</div>
              <div style={{ fontSize: 28, fontWeight: 800 }}>+{reg.last_7d.toLocaleString('ru-RU')}</div>
            </div>
            <div>
              <div className="muted" style={{ fontSize: 12 }}>За 30 дней</div>
              <div style={{ fontSize: 28, fontWeight: 800 }}>+{reg.last_30d.toLocaleString('ru-RU')}</div>
            </div>
          </div>
          {/* Күнделікті бар-график (соңғы 30 күн) */}
          {(() => {
            const max = Math.max(1, ...reg.daily.map((d) => d.count));
            return (
              <div style={{ display: 'flex', alignItems: 'flex-end', gap: 3, height: 90 }}>
                {reg.daily.map((d, i) => {
                  const isToday = i === reg.daily.length - 1;
                  return (
                    <div
                      key={d.day}
                      title={`${d.day}: ${d.count}`}
                      style={{
                        flex: 1,
                        height: `${Math.max(3, (d.count / max) * 100)}%`,
                        background: isToday ? 'var(--gold)' : 'var(--accent)',
                        opacity: isToday ? 1 : 0.55,
                        borderRadius: '3px 3px 0 0',
                        minWidth: 4,
                      }}
                    />
                  );
                })}
              </div>
            );
          })()}
          <div className="muted" style={{ fontSize: 11, marginTop: 6 }}>Регистрации по дням за последние 30 дней (наведите на столбец для даты)</div>
        </div>
      )}

      {/* По странам (топ) — быстрый срез географии */}
      {topCountries.length > 0 && (
        <div className="card" style={{ margin: '0 0 16px' }}>
          <div className="muted" style={{ fontSize: 12, marginBottom: 8 }}>🌍 По странам регистрации</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 10 }}>
            {topCountries.map((c) => (
              <span key={c.country} style={{ fontSize: 14 }}>
                {cMeta(c.country).flag} {cMeta(c.country).name}: <b>{c.count.toLocaleString('ru-RU')}</b>
                <span className="muted" style={{ fontSize: 12 }}> ({c.pct}%)</span>
              </span>
            ))}
          </div>
        </div>
      )}

      <form
        onSubmit={(e) => {
          e.preventDefault();
          load();
        }}
        style={{ display: 'flex', gap: 8, margin: '12px 0 18px' }}
      >
        <input
          placeholder="Поиск: телефон, имя, промокод"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={{ flex: 1 }}
        />
        <button type="submit">Найти</button>
      </form>

      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
          <thead>
            <tr style={{ textAlign: 'left', color: 'var(--muted)' }}>
              <th style={{ padding: 10 }}>Телефон</th>
              <th style={{ padding: 10 }}>Имя</th>
              <th style={{ padding: 10 }}>Страна</th>
              <th style={{ padding: 10 }}>Город</th>
              <th style={{ padding: 10 }}>Регистрация</th>
              <th style={{ padding: 10 }}>Роль</th>
              <th style={{ padding: 10 }}>Бонус</th>
              <th style={{ padding: 10 }}>Действие</th>
            </tr>
          </thead>
          <tbody>
            {items.map((u) => (
              <tr key={u.id} style={{ borderTop: '1px solid var(--border)', opacity: u.is_blocked ? 0.5 : 1 }}>
                <td style={{ padding: 10, fontFamily: 'monospace' }}>{u.phone}</td>
                <td style={{ padding: 10 }}>{u.name || '—'}</td>
                <td style={{ padding: 10, whiteSpace: 'nowrap' }}>{cMeta(u.country).flag} {cMeta(u.country).name}</td>
                <td style={{ padding: 10 }}>{u.city || '—'}</td>
                <td style={{ padding: 10, whiteSpace: 'nowrap' }}>{fmtDate(u.created_at)}</td>
                <td style={{ padding: 10 }}>
                  {u.is_admin && <span className="badge" style={{ background: '#7c3aed', color: '#fff' }}>admin</span>}{' '}
                  {u.is_verified_trader && <span className="badge" style={{ background: '#2563eb', color: '#fff' }}>провайдер</span>}{' '}
                  {u.is_blocked && <span className="badge" style={{ background: '#dc2626', color: '#fff' }}>blocked</span>}
                </td>
                <td style={{ padding: 10 }}>{u.bonus_balance}</td>
                <td style={{ padding: 10 }}>
                  <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                    <button
                      className="ghost"
                      disabled={busyId === u.id}
                      onClick={() => setRole(u, { is_verified_trader: !u.is_verified_trader })}
                    >
                      {u.is_verified_trader ? '− провайдер' : '+ провайдер'}
                    </button>
                    <button
                      className="ghost"
                      disabled={busyId === u.id}
                      onClick={() => setRole(u, { is_admin: !u.is_admin })}
                    >
                      {u.is_admin ? '− admin' : '+ admin'}
                    </button>
                    <button
                      className={u.is_blocked ? '' : 'ghost'}
                      disabled={busyId === u.id}
                      onClick={() => toggleBlock(u)}
                    >
                      {u.is_blocked ? 'Разблок.' : 'Блок'}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
            {items.length === 0 && (
              <tr>
                <td colSpan={8} style={{ padding: 16, color: 'var(--muted)' }}>Нет пользователей</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
