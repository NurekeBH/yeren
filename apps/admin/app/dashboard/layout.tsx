'use client';

import { useEffect, useState } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import Link from 'next/link';
import { api, clearToken, getToken } from '@/lib/api';

// badgeKey — /admin/pending-counts кілті (растау/қарау керек элементтер саны).
const NAV = [
  { href: '/dashboard', label: 'Обзор', icon: '📊' },
  { href: '/dashboard/finance', label: 'Финансы / Бонусы', icon: '💰' },
  { href: '/dashboard/signals-bi', label: 'Pay-per-Signal', icon: '💎' },
  { href: '/dashboard/payouts', label: 'Выплаты трейдерам', icon: '💸' },
  { href: '/dashboard/users', label: 'Пользователи', icon: '👥' },
  { href: '/dashboard/applications', label: 'Заявки провайдеров', icon: '📝', badgeKey: 'applications' },
  { href: '/dashboard/subscriptions', label: 'Подписки', icon: '💳' },
  { href: '/dashboard/signals', label: 'Сигналы / Идеи', icon: '📈' },
  { href: '/dashboard/providers', label: 'Провайдеры', icon: '🏆' },
  { href: '/dashboard/intel', label: 'Market Intel', icon: '📰' },
  { href: '/dashboard/events', label: 'События', icon: '📅', badgeKey: 'events' },
  { href: '/dashboard/library', label: 'Библиотека', icon: '📚' },
  { href: '/dashboard/courses', label: 'Курсы', icon: '🎬' },
  { href: '/dashboard/reports', label: 'Жалобы на посты', icon: '🚩', badgeKey: 'reports' },
  { href: '/dashboard/support', label: 'Поддержка', icon: '🆘', badgeKey: 'support' },
];

type Counts = { applications: number; events: number; reports: number; support: number };

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [ready, setReady] = useState(false);
  const [counts, setCounts] = useState<Counts | null>(null);

  useEffect(() => {
    if (!getToken()) router.replace('/login');
    else setReady(true);
  }, [router]);

  // Назар керек элементтер санын тарту (әр 60 сек жаңартылады) — pathname өзгергенде де.
  useEffect(() => {
    if (!ready) return;
    let alive = true;
    const fetchCounts = () =>
      api<Counts>('/admin/pending-counts').then((c) => { if (alive) setCounts(c); }).catch(() => {});
    fetchCounts();
    const t = setInterval(fetchCounts, 60_000);
    return () => { alive = false; clearInterval(t); };
  }, [ready, pathname]);

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
            const badge = n.badgeKey && counts ? (counts as any)[n.badgeKey] as number : 0;
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
                <span style={{ flex: 1 }}>{n.label}</span>
                {badge > 0 && (
                  <span
                    title="Требует действия"
                    style={{
                      minWidth: 20,
                      height: 20,
                      padding: '0 6px',
                      borderRadius: 10,
                      background: '#DC2626',
                      color: '#fff',
                      fontSize: 12,
                      fontWeight: 700,
                      display: 'inline-flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    {badge}
                  </span>
                )}
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
