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

const empty = {
  name: '',
  avatar: '📊',
  bio: '',
  win_rate: '0.6',
  avg_rr: '2.0',
  rating: '4.5',
  price_per_month: '0',
  trades_count: '0',
};

export default function ProvidersPage() {
  const [items, setItems] = useState<Provider[]>([]);
  const [form, setForm] = useState({ ...empty });
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);

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

  async function create(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setErr('');
    try {
      await api('/providers', {
        method: 'POST',
        body: {
          name: form.name,
          avatar: form.avatar,
          bio: form.bio,
          win_rate: Number(form.win_rate),
          avg_rr: Number(form.avg_rr),
          rating: Number(form.rating),
          price_per_month: Number(form.price_per_month),
          trades_count: Number(form.trades_count),
        },
      });
      setForm({ ...empty });
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
    }
  }

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
        <h2>Добавить провайдера</h2>
        <form onSubmit={create}>
          <div className="grid2">
            <div>
              <label>Имя</label>
              <input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
            </div>
            <div>
              <label>Аватар (эмодзи)</label>
              <input value={form.avatar} onChange={(e) => setForm({ ...form, avatar: e.target.value })} />
            </div>
          </div>
          <label>Описание</label>
          <textarea rows={2} value={form.bio} onChange={(e) => setForm({ ...form, bio: e.target.value })} />
          <div className="grid2">
            <div>
              <label>Win Rate (0–1)</label>
              <input value={form.win_rate} onChange={(e) => setForm({ ...form, win_rate: e.target.value })} />
            </div>
            <div>
              <label>Avg RR</label>
              <input value={form.avg_rr} onChange={(e) => setForm({ ...form, avg_rr: e.target.value })} />
            </div>
          </div>
          <div className="grid2">
            <div>
              <label>Рейтинг (0–5)</label>
              <input value={form.rating} onChange={(e) => setForm({ ...form, rating: e.target.value })} />
            </div>
            <div>
              <label>Цена ₸/мес (0 = бесплатно)</label>
              <input
                value={form.price_per_month}
                onChange={(e) => setForm({ ...form, price_per_month: e.target.value })}
              />
            </div>
          </div>
          <button style={{ marginTop: 12 }} disabled={busy}>
            {busy ? 'Создание…' : 'Создать (verified)'}
          </button>
        </form>
      </div>

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
