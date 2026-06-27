'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Report = {
  id: string;
  reason: string;
  note: string | null;
  status: string;
  action: string | null;
  created_at: string;
  post_id: string;
  post_text: string;
  image_url: string | null;
  provider_name: string | null;
  reporter_name: string | null;
  reporter_phone: string | null;
};

const REASON_LABEL: Record<string, string> = {
  sexual: '🔞 Сексуальный контент',
  harmful: '⚠️ Вредный контент',
  spam: '🗑️ Спам',
  harassment: '😡 Оскорбление',
  misinfo: '❌ Дезинформация',
  other: 'Другое',
};

export default function ReportsPage() {
  const [items, setItems] = useState<Report[]>([]);
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState('');

  async function load() {
    setErr('');
    try {
      const r = await api<{ reports: Report[] }>('/admin/reports');
      setItems(r.reports);
    } catch (e: any) {
      setErr(e.message);
    }
  }
  useEffect(() => {
    load();
  }, []);

  async function resolve(r: Report, action: 'delete' | 'dismiss') {
    if (action === 'delete' && !confirm('Удалить пост? Это действие необратимо.')) return;
    setBusy(r.id);
    try {
      await api(`/admin/reports/${r.id}/resolve`, { method: 'POST', body: { action } });
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy('');
    }
  }

  const open = items.filter((r) => r.status === 'open');

  return (
    <div>
      <h1>Жалобы на посты</h1>
      <p className="muted">Жалобы пользователей на посты трейдеров. Проверьте и удалите пост или оставьте.</p>
      {err && <div className="err">{err}</div>}

      <div className="card">
        <span className="tag red">Новых: {open.length}</span>
        {items.length === 0 && <div className="muted" style={{ marginTop: 10 }}>Жалоб нет.</div>}
        {items.map((r) => (
          <div
            key={r.id}
            className="card"
            style={{ borderColor: r.status === 'open' ? 'var(--red)' : 'var(--border)', background: r.status === 'open' ? '#fff' : 'var(--bg)' }}
          >
            <div className="row" style={{ justifyContent: 'space-between', alignItems: 'center' }}>
              <strong>{REASON_LABEL[r.reason] || r.reason}</strong>
              <span className={`tag ${r.status === 'open' ? 'red' : 'green'}`}>
                {r.status === 'open' ? 'новая' : r.action === 'deleted' ? 'пост удалён' : 'оставлено'}
              </span>
            </div>
            {r.note && <p className="muted" style={{ margin: '6px 0' }}>«{r.note}»</p>}
            <div className="card" style={{ background: 'var(--bg)', margin: '8px 0' }}>
              <div className="muted" style={{ fontSize: 12, marginBottom: 4 }}>
                Пост · {r.provider_name || '—'}
              </div>
              <div style={{ whiteSpace: 'pre-wrap' }}>{r.post_text}</div>
              {r.image_url && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={r.image_url} alt="" style={{ maxWidth: 220, marginTop: 8, borderRadius: 8 }} />
              )}
            </div>
            <div className="muted" style={{ fontSize: 12 }}>
              Пожаловался: {r.reporter_name || '—'} {r.reporter_phone || ''} · {new Date(r.created_at).toLocaleString()}
            </div>
            {r.status === 'open' && (
              <div className="row" style={{ marginTop: 10 }}>
                <button className="danger" disabled={busy === r.id} onClick={() => resolve(r, 'delete')}>
                  🗑️ Удалить пост
                </button>
                <button className="ghost" disabled={busy === r.id} onClick={() => resolve(r, 'dismiss')}>
                  Оставить (не нарушает)
                </button>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
