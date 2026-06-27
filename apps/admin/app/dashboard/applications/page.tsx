'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Application = {
  id: string;
  user_id: string;
  name: string;
  phone: string;
  years: string | null;
  about: string;
  proof: string | null;
  status: string;
  created_at: string;
};

export default function ApplicationsPage() {
  const [items, setItems] = useState<Application[]>([]);
  const [err, setErr] = useState('');
  const [busyId, setBusyId] = useState('');

  async function load() {
    try {
      const r = await api<{ applications: Application[] }>('/admin/trader-applications?status=pending');
      setItems(r.applications);
    } catch (e: any) {
      setErr(e.message);
    }
  }
  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function review(a: Application, action: 'approve' | 'reject') {
    setBusyId(a.id);
    setErr('');
    try {
      await api(`/admin/trader-applications/${a.id}/${action}`, { method: 'POST' });
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusyId('');
    }
  }

  return (
    <div>
      <h1>Заявки провайдеров</h1>
      {err && <div className="err">{err}</div>}
      {items.length === 0 && <div className="muted" style={{ marginTop: 12 }}>Нет заявок на проверке</div>}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginTop: 14 }}>
        {items.map((a) => (
          <div className="card" key={a.id}>
            <div style={{ display: 'flex', justifyContent: 'space-between', gap: 12 }}>
              <div>
                <div style={{ fontWeight: 700 }}>{a.name || '—'} <span className="muted" style={{ fontFamily: 'monospace', fontWeight: 400 }}>{a.phone}</span></div>
                <div className="muted" style={{ fontSize: 12, marginTop: 2 }}>
                  Опыт: {a.years || '—'} лет
                </div>
                <div style={{ marginTop: 8, fontSize: 14 }}>{a.about}</div>
                {a.proof && (
                  <a href={a.proof} target="_blank" rel="noreferrer" style={{ fontSize: 13, color: 'var(--gold)' }}>
                    {a.proof}
                  </a>
                )}
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8, flexShrink: 0 }}>
                <button disabled={busyId === a.id} onClick={() => review(a, 'approve')}>Одобрить</button>
                <button className="ghost" disabled={busyId === a.id} onClick={() => review(a, 'reject')}>Отклонить</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
