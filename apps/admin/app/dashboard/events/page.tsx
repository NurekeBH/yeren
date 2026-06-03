'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Ev = {
  id: string;
  type: string;
  title: string;
  speaker: string;
  city: string;
  is_online: boolean;
  starts_at: string;
  price: number;
  youtube_id?: string;
};
type App = { id: string; name: string; phone: string; comment: string; created_at: string };

const empty = {
  type: 'masterclass',
  title: '',
  speaker: '',
  city: 'Онлайн',
  is_online: true,
  starts_at: '',
  price: '0',
  description: '',
  youtube_id: '',
};

export default function EventsPage() {
  const [items, setItems] = useState<Ev[]>([]);
  const [form, setForm] = useState({ ...empty });
  const [apps, setApps] = useState<Record<string, App[]>>({});
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);

  async function load() {
    try {
      const r = await api<{ events: Ev[] }>('/events');
      setItems(r.events);
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
      await api('/events', {
        method: 'POST',
        body: {
          type: form.type,
          title: form.title,
          speaker: form.speaker,
          city: form.city,
          is_online: form.is_online,
          starts_at: new Date(form.starts_at).toISOString(),
          price: Number(form.price),
          description: form.description,
          youtube_id: form.youtube_id || undefined,
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

  async function showApps(id: string) {
    try {
      const r = await api<{ applications: App[] }>(`/events/${id}/applications`);
      setApps((prev) => ({ ...prev, [id]: r.applications }));
    } catch (e: any) {
      setErr(e.message);
    }
  }

  return (
    <div>
      <h1>События</h1>
      {err && <div className="err">{err}</div>}

      <div className="card">
        <h2>Создать событие</h2>
        <form onSubmit={create}>
          <div className="grid2">
            <div>
              <label>Тип</label>
              <select value={form.type} onChange={(e) => setForm({ ...form, type: e.target.value })}>
                <option value="masterclass">Мастер-класс</option>
                <option value="live_trade">Лайв-трейд</option>
                <option value="webinar">Вебинар</option>
              </select>
            </div>
            <div>
              <label>Спикер</label>
              <input value={form.speaker} onChange={(e) => setForm({ ...form, speaker: e.target.value })} />
            </div>
          </div>
          <label>Название</label>
          <input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} />
          <div className="grid2">
            <div>
              <label>Город</label>
              <input value={form.city} onChange={(e) => setForm({ ...form, city: e.target.value })} />
            </div>
            <div>
              <label>Дата и время</label>
              <input
                type="datetime-local"
                value={form.starts_at}
                onChange={(e) => setForm({ ...form, starts_at: e.target.value })}
              />
            </div>
          </div>
          <div className="grid2">
            <div>
              <label>Цена ₸ (0 = бесплатно)</label>
              <input value={form.price} onChange={(e) => setForm({ ...form, price: e.target.value })} />
            </div>
            <div>
              <label>YouTube ID (опц.)</label>
              <input value={form.youtube_id} onChange={(e) => setForm({ ...form, youtube_id: e.target.value })} />
            </div>
          </div>
          <label className="row" style={{ alignItems: 'center', gap: 8 }}>
            <input
              type="checkbox"
              style={{ width: 'auto' }}
              checked={form.is_online}
              onChange={(e) => setForm({ ...form, is_online: e.target.checked })}
            />
            Онлайн
          </label>
          <label>Описание</label>
          <textarea
            rows={3}
            value={form.description}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
          />
          <button style={{ marginTop: 12 }} disabled={busy}>
            {busy ? 'Создание…' : 'Создать'}
          </button>
        </form>
      </div>

      {items.map((ev) => (
        <div className="card" key={ev.id}>
          <div className="row" style={{ justifyContent: 'space-between' }}>
            <div>
              <strong>{ev.title}</strong>
              <div className="muted" style={{ fontSize: 12 }}>
                {ev.speaker} · {ev.city} · {new Date(ev.starts_at).toLocaleString()} ·{' '}
                {Number(ev.price) > 0 ? `${ev.price} ₸` : 'бесплатно'}
              </div>
            </div>
            <button className="ghost" onClick={() => showApps(ev.id)}>
              Заявки
            </button>
          </div>
          {apps[ev.id] && (
            <table style={{ marginTop: 12 }}>
              <thead>
                <tr>
                  <th>Имя</th>
                  <th>Телефон</th>
                  <th>Комментарий</th>
                </tr>
              </thead>
              <tbody>
                {apps[ev.id].length === 0 ? (
                  <tr>
                    <td colSpan={3} className="muted">
                      Заявок нет
                    </td>
                  </tr>
                ) : (
                  apps[ev.id].map((a) => (
                    <tr key={a.id}>
                      <td>{a.name}</td>
                      <td>{a.phone}</td>
                      <td className="muted">{a.comment}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          )}
        </div>
      ))}
    </div>
  );
}
