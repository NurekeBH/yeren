'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Sub = {
  id: string;
  user_id: string;
  phone?: string;
  name?: string;
  amount: number;
  currency: string;
  receipt_url?: string;
  submitted_at?: string;
};

export default function SubscriptionsPage() {
  const [items, setItems] = useState<Sub[]>([]);
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState<string | null>(null);

  async function load() {
    try {
      const r = await api<{ items: Sub[] }>('/subscription/pending');
      setItems(r.items);
    } catch (e: any) {
      setErr(e.message);
    }
  }
  useEffect(() => {
    load();
  }, []);

  async function approve(id: string) {
    setBusy(id);
    try {
      await api(`/subscription/${id}/approve`, { method: 'POST', body: { days: 30 } });
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(null);
    }
  }

  async function reject(id: string) {
    setBusy(id);
    try {
      await api(`/subscription/${id}/reject`, { method: 'POST', body: { notes: 'Чек не подтверждён' } });
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(null);
    }
  }

  return (
    <div>
      <h1>Подписки на проверке</h1>
      <p className="muted">Kaspi чек → активация на 30 дней (30 000 ₸).</p>
      {err && <div className="err">{err}</div>}
      <div className="card">
        {items.length === 0 ? (
          <div className="muted">Нет заявок на проверке.</div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Пользователь</th>
                <th>Сумма</th>
                <th>Чек</th>
                <th>Подано</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {items.map((s) => (
                <tr key={s.id}>
                  <td>{s.name || s.phone || s.user_id.slice(0, 8)}</td>
                  <td>
                    {s.amount} {s.currency}
                  </td>
                  <td>
                    {s.receipt_url ? (
                      <a href={s.receipt_url} target="_blank" rel="noreferrer">
                        открыть
                      </a>
                    ) : (
                      <span className="muted">—</span>
                    )}
                  </td>
                  <td className="muted">{s.submitted_at ? new Date(s.submitted_at).toLocaleString() : '—'}</td>
                  <td>
                    <div className="row">
                      <button className="green" disabled={busy === s.id} onClick={() => approve(s.id)}>
                        Активировать
                      </button>
                      <button className="danger" disabled={busy === s.id} onClick={() => reject(s.id)}>
                        Отклонить
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
