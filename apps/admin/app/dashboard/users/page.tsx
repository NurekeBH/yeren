'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type User = {
  id: string;
  phone: string;
  name: string;
  city: string;
  is_admin: boolean;
  is_verified_trader: boolean;
  is_blocked: boolean;
  promo_code: string | null;
  bonus_balance: number;
  referral_count: number;
  created_at: string;
};

export default function UsersPage() {
  const [items, setItems] = useState<User[]>([]);
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
  useEffect(() => {
    load();
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

  return (
    <div>
      <h1>Пользователи</h1>
      {err && <div className="err">{err}</div>}
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
              <th style={{ padding: 10 }}>Роль</th>
              <th style={{ padding: 10 }}>Бонус</th>
              <th style={{ padding: 10 }}>Рефералы</th>
              <th style={{ padding: 10 }}>Действие</th>
            </tr>
          </thead>
          <tbody>
            {items.map((u) => (
              <tr key={u.id} style={{ borderTop: '1px solid var(--border)', opacity: u.is_blocked ? 0.5 : 1 }}>
                <td style={{ padding: 10, fontFamily: 'monospace' }}>{u.phone}</td>
                <td style={{ padding: 10 }}>{u.name || '—'}{u.city ? ` · ${u.city}` : ''}</td>
                <td style={{ padding: 10 }}>
                  {u.is_admin && <span className="badge" style={{ background: '#7c3aed', color: '#fff' }}>admin</span>}{' '}
                  {u.is_verified_trader && <span className="badge" style={{ background: '#2563eb', color: '#fff' }}>trader</span>}{' '}
                  {u.is_blocked && <span className="badge" style={{ background: '#dc2626', color: '#fff' }}>blocked</span>}
                </td>
                <td style={{ padding: 10 }}>{u.bonus_balance}</td>
                <td style={{ padding: 10 }}>{u.referral_count}</td>
                <td style={{ padding: 10 }}>
                  <button
                    className={u.is_blocked ? '' : 'ghost'}
                    disabled={busyId === u.id}
                    onClick={() => toggleBlock(u)}
                  >
                    {u.is_blocked ? 'Разблокировать' : 'Заблокировать'}
                  </button>
                </td>
              </tr>
            ))}
            {items.length === 0 && (
              <tr>
                <td colSpan={6} style={{ padding: 16, color: 'var(--muted)' }}>Нет пользователей</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
