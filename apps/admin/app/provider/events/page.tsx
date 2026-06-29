'use client';

import { useEffect, useState } from 'react';
import { api, uploadImage } from '@/lib/api';

type Ev = {
  id: string; type: string; title: string; speaker: string; city: string;
  is_online: boolean; starts_at: string; price: number; poster_url?: string | null; is_approved: boolean;
};

const empty = {
  type: 'masterclass', title: '', speaker: '', city: 'Онлайн', is_online: true,
  starts_at: '', price: '0', description: '', poster_url: '',
};

export default function ProviderEventsPage() {
  const [items, setItems] = useState<Ev[]>([]);
  const [form, setForm] = useState({ ...empty });
  const [cities, setCities] = useState<string[]>([]);
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);
  const [uploading, setUploading] = useState(false);

  async function load() {
    try {
      const r = await api<{ events: Ev[] }>('/provider/events');
      setItems(r.events);
    } catch (e: any) { setErr(e.message); }
  }
  useEffect(() => {
    load();
    api<{ cities: { name: string }[] }>('/cities').then((r) => setCities(r.cities.map((c) => c.name))).catch(() => {});
  }, []);

  async function onCover(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploading(true); setErr('');
    try {
      const url = await uploadImage(file);
      setForm((f) => ({ ...f, poster_url: url }));
    } catch (e: any) { setErr(e.message); } finally { setUploading(false); }
  }

  async function create(e: React.FormEvent) {
    e.preventDefault();
    if (!form.starts_at) { setErr('Укажите дату и время'); return; }
    setBusy(true); setErr('');
    try {
      await api('/events', {
        method: 'POST',
        body: {
          type: form.type, title: form.title, speaker: form.speaker, city: form.city,
          is_online: form.is_online, starts_at: new Date(form.starts_at).toISOString(),
          price: Number(form.price), description: form.description,
          poster_url: form.poster_url || undefined,
        },
      });
      setForm({ ...empty });
      await load();
    } catch (e: any) { setErr(e.message); } finally { setBusy(false); }
  }

  async function del(id: string) {
    if (!confirm('Удалить событие?')) return;
    try { await api(`/provider/events/${id}`, { method: 'DELETE' }); await load(); }
    catch (e: any) { setErr(e.message); }
  }

  return (
    <div>
      <h1>Мои события</h1>
      <p className="muted">Создайте событие — оно уйдёт на проверку администратору. После одобрения появится в приложении.</p>
      {err && <div className="err">{err}</div>}

      <div className="card">
        <h2 style={{ marginTop: 0 }}>Создать событие</h2>
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
            <div><label>Спикер</label><input value={form.speaker} onChange={(e) => setForm({ ...form, speaker: e.target.value })} /></div>
          </div>
          <label>Название</label>
          <input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} />
          <label>Обложка (фото, необяз.)</label>
          <input type="file" accept="image/*" onChange={onCover} disabled={uploading} />
          {uploading && <span className="muted"> загрузка…</span>}
          {form.poster_url && (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={form.poster_url} alt="" style={{ display: 'block', maxWidth: 220, borderRadius: 8, marginTop: 8 }} />
          )}
          <div className="grid2">
            <div>
              <label>Город</label>
              <input list="cities-dl" value={form.city} onChange={(e) => setForm({ ...form, city: e.target.value })} placeholder="начните вводить…" />
              <datalist id="cities-dl">{cities.map((c) => <option key={c} value={c} />)}</datalist>
            </div>
            <div><label>Дата и время</label>
              <input type="datetime-local" value={form.starts_at} onChange={(e) => setForm({ ...form, starts_at: e.target.value })} /></div>
          </div>
          <label>Цена ₸ (0 = бесплатно)</label>
          <input value={form.price} onChange={(e) => setForm({ ...form, price: e.target.value })} />
          <label className="row" style={{ alignItems: 'center', gap: 8 }}>
            <input type="checkbox" style={{ width: 'auto' }} checked={form.is_online} onChange={(e) => setForm({ ...form, is_online: e.target.checked })} />
            Онлайн
          </label>
          <label>Описание</label>
          <textarea rows={3} value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} />
          <button style={{ marginTop: 12 }} disabled={busy}>{busy ? 'Создание…' : 'Отправить на проверку'}</button>
        </form>
      </div>

      {items.map((ev) => (
        <div className="card" key={ev.id} style={!ev.is_approved ? { borderColor: '#D97706' } : undefined}>
          <div className="row" style={{ justifyContent: 'space-between' }}>
            <div>
              <div className="row" style={{ gap: 8, alignItems: 'center' }}>
                <strong>{ev.title}</strong>
                {ev.is_approved
                  ? <span style={{ fontSize: 11, color: '#059669', fontWeight: 700 }}>✓ опубликовано</span>
                  : <span style={{ fontSize: 11, color: '#D97706', fontWeight: 700 }}>⏳ на проверке</span>}
              </div>
              <div className="muted" style={{ fontSize: 12 }}>
                {ev.speaker} · {ev.city} · {new Date(ev.starts_at).toLocaleString()} · {Number(ev.price) > 0 ? `${ev.price} ₸` : 'бесплатно'}
              </div>
            </div>
            <button className="danger" onClick={() => del(ev.id)}>🗑️</button>
          </div>
        </div>
      ))}
    </div>
  );
}
