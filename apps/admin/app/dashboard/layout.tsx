'use client';

import { useEffect, useState } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import Link from 'next/link';
import { clearToken, getToken } from '@/lib/api';

const NAV = [
  { href: '/dashboard', label: 'Обзор', icon: '📊' },
  { href: '/dashboard/users', label: 'Пользователи', icon: '👥' },
  { href: '/dashboard/applications', label: 'Заявки провайдеров', icon: '📝' },
  { href: '/dashboard/subscriptions', label: 'Подписки', icon: '💳' },
  { href: '/dashboard/signals', label: 'Сигналы / Идеи', icon: '📈' },
  { href: '/dashboard/providers', label: 'Провайдеры', icon: '🏆' },
  { href: '/dashboard/intel', label: 'Market Intel', icon: '📰' },
  { href: '/dashboard/events', label: 'События', icon: '📅' },
  { href: '/dashboard/library', label: 'Библиотека', icon: '📚' },
  { href: '/dashboard/courses', label: 'Курсы', icon: '🎬' },
  { href: '/dashboard/reports', label: 'Жалобы на посты', icon: '🚩' },
  { href: '/dashboard/support', label: 'Поддержка', icon: '🆘' },
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
          width: 248,
          background: 'var(--panel)',
          borderRight: '1px solid var(--border)',
          padding: 18,
          flexShrink: 0,
        }}
      >
        <div style={{ color: 'var(--gold)', fontWeight: 800, fontSize: 22, marginBottom: 24 }}>
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
