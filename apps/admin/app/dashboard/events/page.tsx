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
  poster_url?: string | null;
  is_approved: boolean;
  creator_name?: string | null;
  creator_phone?: string | null;
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
  const [cities, setCities] = useState<string[]>([]);
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);

  async function load() {
    try {
      // Барлық оқиғалар (pending қоса) — модерация үшін.
      const r = await api<{ events: Ev[] }>('/admin/events');
      setItems(r.events);
    } catch (e: any) {
      setErr(e.message);
    }
  }
  useEffect(() => {
    load();
    api<{ cities: { name: string }[] }>('/cities').then((r) => setCities(r.cities.map((c) => c.name))).catch(() => {});
  }, []);

  async function approve(id: string) {
    try {
      await api(`/admin/events/${id}/approve`, { method: 'POST' });
      await load();
    } catch (e: any) {
      setErr(e.message);
    }
  }

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

  async function delEvent(id: string) {
    if (!confirm('Удалить событие?')) return;
    try {
      await api(`/events/${id}`, { method: 'DELETE' });
      await load();
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
              <input list="cities-dl" value={form.city} onChange={(e) => setForm({ ...form, city: e.target.value })} placeholder="начните вводить…" />
              <datalist id="cities-dl">{cities.map((c) => <option key={c} value={c} />)}</datalist>
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

      {items.some((e) => !e.is_approved) && (
        <h2 style={{ marginTop: 24, color: '#D97706' }}>⏳ На модерации (от провайдеров)</h2>
      )}
      {items.map((ev) => (
        <div className="card" key={ev.id} style={!ev.is_approved ? { borderColor: '#D97706' } : undefined}>
          <div className="row" style={{ justifyContent: 'space-between' }}>
            <div>
              <div className="row" style={{ gap: 8, alignItems: 'center' }}>
                <strong>{ev.title}</strong>
                {ev.is_approved ? (
                  <span style={{ fontSize: 11, color: '#059669', fontWeight: 700 }}>✓ опубликовано</span>
                ) : (
                  <span style={{ fontSize: 11, color: '#D97706', fontWeight: 700, background: '#D9770618', padding: '2px 8px', borderRadius: 12 }}>
                    ⏳ ожидает одобрения
                  </span>
                )}
              </div>
              <div className="muted" style={{ fontSize: 12 }}>
                {ev.speaker} · {ev.city} · {new Date(ev.starts_at).toLocaleString()} ·{' '}
                {Number(ev.price) > 0 ? `${ev.price} ₸` : 'бесплатно'}
                {ev.creator_name && <> · от: {ev.creator_name}</>}
              </div>
              {ev.poster_url && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={ev.poster_url} alt="" style={{ maxWidth: 200, borderRadius: 8, marginTop: 8, display: 'block' }} />
              )}
            </div>
            <div className="row" style={{ gap: 6 }}>
              {!ev.is_approved && (
                <button className="green" onClick={() => approve(ev.id)}>
                  ✓ Одобрить
                </button>
              )}
              <button className="ghost" onClick={() => showApps(ev.id)}>
                Заявки
              </button>
              <button className="danger" onClick={() => delEvent(ev.id)}>
                🗑️
              </button>
            </div>
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
