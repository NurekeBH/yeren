'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Message = {
  id: string;
  text: string;
  resolved: boolean;
  created_at: string;
  phone: string | null;
  name: string | null;
};

export default function SupportPage() {
  const [items, setItems] = useState<Message[]>([]);
  const [err, setErr] = useState('');

  async function load() {
    setErr('');
    try {
      const r = await api<{ messages: Message[] }>('/support');
      setItems(r.messages);
    } catch (e: any) {
      setErr(e.message);
    }
  }
  useEffect(() => {
    load();
  }, []);

  async function resolve(m: Message) {
    try {
      await api(`/support/${m.id}/resolve`, { method: 'POST' });
      await load();
    } catch (e: any) {
      setErr(e.message);
    }
  }

  const open = items.filter((m) => !m.resolved);
  const done = items.filter((m) => m.resolved);

  return (
    <div>
      <h1>Поддержка</h1>
      <p className="muted">Сообщения пользователей из приложения. Сначала — необработанные.</p>
      {err && <div className="err">{err}</div>}

      <div className="card">
        <div className="row" style={{ gap: 16, marginBottom: 10 }}>
          <span className="tag red">Не обработано: {open.length}</span>
          <span className="tag green">Обработано: {done.length}</span>
        </div>
        {items.length === 0 && <div className="muted">Пока нет сообщений.</div>}
        {items.map((m) => (
          <div
            key={m.id}
            className="card"
            style={{ background: m.resolved ? 'var(--bg)' : '#fff', borderColor: m.resolved ? 'var(--border)' : 'var(--accent)' }}
          >
            <div className="row" style={{ justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <strong>{m.name || 'Без имени'}</strong>{' '}
                <span className="muted">{m.phone || ''}</span>
              </div>
              <div className="row" style={{ gap: 10, alignItems: 'center' }}>
                <span className={`tag ${m.resolved ? 'green' : 'red'}`}>
                  {m.resolved ? 'обработано' : 'новое'}
                </span>
                <span className="muted" style={{ fontSize: 12 }}>
                  {new Date(m.created_at).toLocaleString()}
                </span>
              </div>
            </div>
            <p style={{ margin: '8px 0', whiteSpace: 'pre-wrap' }}>{m.text}</p>
            {!m.resolved && (
              <button className="green" onClick={() => resolve(m)}>
                ✓ Отметить обработанным
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
