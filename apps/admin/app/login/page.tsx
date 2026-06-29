'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { api, clearToken, setToken } from '@/lib/api';

export default function LoginPage() {
  const router = useRouter();
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setErr('');
    try {
      const res = await api<{ token: string }>('/auth/login', {
        method: 'POST',
        body: { phone, password },
      });
      setToken(res.token);
      // Рөл бойынша бағыттау: админ → толық панель; расталған трейдер → провайдер панелі.
      const me = await api<{ user: { is_admin?: boolean; is_verified_trader?: boolean } }>('/auth/me');
      if (me.user?.is_admin) {
        router.replace('/dashboard');
      } else if (me.user?.is_verified_trader) {
        router.replace('/provider/courses');
      } else {
        clearToken();
        setErr('Нет доступа. Панель — для админов и провайдеров (верифицированных трейдеров).');
      }
    } catch (e: any) {
      setErr(e.message ?? 'Ошибка входа');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div style={{ maxWidth: 360, margin: '12vh auto', padding: 20 }}>
      <h1 style={{ textAlign: 'center', color: 'var(--gold)' }}>🏆 ALTYN Admin</h1>
      <form className="card" onSubmit={submit}>
        <label>Телефон</label>
        <input value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="+7700..." />
        <label>Пароль</label>
        <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        {err && <div className="err">{err}</div>}
        <button style={{ width: '100%', marginTop: 14 }} disabled={busy}>
          {busy ? 'Вход…' : 'Войти'}
        </button>
        <p className="muted" style={{ fontSize: 12, marginTop: 12 }}>
          Для админов (полный доступ) и провайдеров (свои курсы и события).
        </p>
      </form>
    </div>
  );
}
