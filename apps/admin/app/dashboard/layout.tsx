'use client';

import { useEffect, useState } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import Link from 'next/link';
import { clearToken, getToken } from '@/lib/api';

const NAV = [
  { href: '/dashboard', label: 'Обзор' },
  { href: '/dashboard/users', label: 'Пользователи' },
  { href: '/dashboard/subscriptions', label: 'Подписки' },
  { href: '/dashboard/signals', label: 'Сигналы / Идеи' },
  { href: '/dashboard/providers', label: 'Провайдеры' },
  { href: '/dashboard/intel', label: 'Market Intel' },
  { href: '/dashboard/events', label: 'События' },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    if (!getToken()) router.replace('/login');
    else setReady(true);
  }, [router]);

  if (!ready) return null;

  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      <aside
        style={{
          width: 220,
          background: 'var(--panel)',
          borderRight: '1px solid var(--border)',
          padding: 18,
          flexShrink: 0,
        }}
      >
        <div style={{ color: 'var(--gold)', fontWeight: 800, fontSize: 18, marginBottom: 22 }}>
          🏆 ALTYN
        </div>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
          {NAV.map((n) => {
            const active = pathname === n.href;
            return (
              <Link
                key={n.href}
                href={n.href}
                style={{
                  padding: '9px 11px',
                  borderRadius: 8,
                  color: active ? '#1a1a1a' : 'var(--text)',
                  background: active ? 'var(--gold)' : 'transparent',
                  fontWeight: active ? 700 : 500,
                }}
              >
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
