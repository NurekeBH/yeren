'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Provider = {
  id: string;
  name: string;
  avatar: string;
  win_rate: number;
  avg_rr: number;
  rating: number;
  subscribers: number;
  trades_count: number;
  price_per_month: number;
  verified: boolean;
};

export default function ProvidersPage() {
  const [items, setItems] = useState<Provider[]>([]);
  const [err, setErr] = useState('');

  async function load() {
    try {
      const r = await api<{ providers: Provider[] }>('/providers');
      setItems(r.providers);
    } catch (e: any) {
      setErr(e.message);
    }
  }
  useEffect(() => {
    load();
  }, []);

  async function toggleVerify(p: Provider) {
    try {
      await api(`/providers/${p.id}/verify`, { method: 'PATCH', body: { verified: !p.verified } });
      await load();
    } catch (e: any) {
      setErr(e.message);
    }
  }

  return (
    <div>
      <h1>Провайдеры сигналов</h1>
      {err && <div className="err">{err}</div>}

      <div className="card">
        <table>
          <thead>
            <tr>
              <th>Провайдер</th>
              <th>Win</th>
              <th>RR</th>
              <th>★</th>
              <th>Подписчики</th>
              <th>Цена</th>
              <th>Статус</th>
            </tr>
          </thead>
          <tbody>
            {items.map((p) => (
              <tr key={p.id}>
                <td>
                  {p.avatar} {p.name}
                </td>
                <td>{Math.round(Number(p.win_rate) * 100)}%</td>
                <td>1:{Number(p.avg_rr).toFixed(1)}</td>
                <td>{Number(p.rating).toFixed(1)}</td>
                <td>{p.subscribers}</td>
                <td>{Number(p.price_per_month) > 0 ? `${p.price_per_month} ₸` : 'free'}</td>
                <td>
                  <button className={p.verified ? 'green' : 'ghost'} onClick={() => toggleVerify(p)}>
                    {p.verified ? '✓ verified' : 'не проверен'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
