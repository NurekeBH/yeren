'use client';

import { useEffect, useState } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import Link from 'next/link';
import { api, clearToken, getToken } from '@/lib/api';

// Провайдер панелі — ШЕКТЕУЛІ: тек өз курстары мен оқиғалары.
const NAV = [
  { href: '/provider/courses', label: 'Мои курсы', icon: '🎬' },
  { href: '/provider/events', label: 'Мои события', icon: '📅' },
];

export default function ProviderLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [ready, setReady] = useState(false);
  const [name, setName] = useState('');

  useEffect(() => {
    if (!getToken()) {
      router.replace('/login');
      return;
    }
    // Рөлді тексеру: тек расталған трейдер (немесе админ көре алады).
    api<{ user: { is_admin?: boolean; is_verified_trader?: boolean; name?: string } }>('/auth/me')
      .then((me) => {
        if (me.user?.is_verified_trader || me.user?.is_admin) {
          setName(me.user?.name || 'Провайдер');
          setReady(true);
        } else {
          clearToken();
          router.replace('/login');
        }
      })
      .catch(() => router.replace('/login'));
  }, [router]);

  if (!ready) return null;

  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      <aside
        style={{
          width: 248,
          background: 'var(--panel)',
          borderRight: '1px solid var(--border)',
          padding: 18,
          flexShrink: 0,
        }}
      >
        <div style={{ color: 'var(--gold)', fontWeight: 800, fontSize: 22, marginBottom: 4 }}>🏆 ALTYN</div>
        <div className="muted" style={{ fontSize: 12, marginBottom: 24 }}>Провайдер · {name}</div>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
          {NAV.map((n) => {
            const active = pathname === n.href;
            return (
              <Link
                key={n.href}
                href={n.href}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 10,
                  padding: '11px 13px',
                  borderRadius: 10,
                  fontSize: 15.5,
                  color: active ? '#fff' : 'var(--text)',
                  background: active ? 'var(--accent)' : 'transparent',
                  fontWeight: active ? 700 : 500,
                }}
              >
                <span style={{ fontSize: 18 }}>{n.icon}</span>
                {n.label}
              </Link>
            );
          })}
        </nav>
        <button
          className="ghost"
          style={{ marginTop: 24, width: '100%' }}
          onClick={() => {
            clearToken();
            router.replace('/login');
          }}
        >
          Выйти
        </button>
      </aside>
      <main style={{ flex: 1, padding: 28, maxWidth: 1000 }}>{children}</main>
    </div>
  );
}
