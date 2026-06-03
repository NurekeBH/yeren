'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Post = {
  id: string;
  source: string;
  text: string;
  impact: string;
  is_urgent: boolean;
  published_at: string;
};

const empty = { source: 'Manual', text: '', impact: 'neutral', is_urgent: false };

export default function IntelPage() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [form, setForm] = useState({ ...empty });
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState('');

  async function load() {
    try {
      const r = await api<{ posts: Post[] }>('/intel?limit=40');
      setPosts(r.posts);
    } catch (e: any) {
      setErr(e.message);
    }
  }
  useEffect(() => {
    load();
  }, []);

  async function publish(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setErr('');
    try {
      await api('/intel', {
        method: 'POST',
        body: { source: form.source, text: form.text, impact: form.impact, is_urgent: form.is_urgent },
      });
      setForm({ ...empty });
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
    }
  }

  async function ingest() {
    setBusy(true);
    setErr('');
    setMsg('');
    try {
      const r = await api<{ inserted: number; sources: string[] }>('/intel/ingest', { method: 'POST' });
      setMsg(
        r.inserted > 0
          ? `Добавлено ${r.inserted} из источников: ${r.sources.join(', ')}`
          : 'Новых новостей нет (или FINNHUB_API_KEY не задан).',
      );
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
    }
  }

  function impactTag(i: string) {
    const cls = i === 'bullish' ? 'green' : i === 'bearish' ? 'red' : 'gold';
    return <span className={`tag ${cls}`}>{i}</span>;
  }

  return (
    <div>
      <h1>Market Intel / Новости</h1>
      <p className="muted">Финансовые новости из разных источников. Urgent → push-уведомление пользователям.</p>

      <div className="card">
        <div className="row" style={{ justifyContent: 'space-between' }}>
          <h2 style={{ margin: 0 }}>Авто-сбор из источников</h2>
          <button className="ghost" disabled={busy} onClick={ingest}>
            Собрать новости (Finnhub)
          </button>
        </div>
        {msg && <p className="muted" style={{ marginTop: 10 }}>{msg}</p>}
      </div>

      <div className="card">
        <h2>Опубликовать вручную</h2>
        <form onSubmit={publish}>
          <div className="grid2">
            <div>
              <label>Источник</label>
              <input value={form.source} onChange={(e) => setForm({ ...form, source: e.target.value })} />
            </div>
            <div>
              <label>Влияние на золото</label>
              <select value={form.impact} onChange={(e) => setForm({ ...form, impact: e.target.value })}>
                <option value="bullish">Bullish</option>
                <option value="bearish">Bearish</option>
                <option value="neutral">Neutral</option>
              </select>
            </div>
          </div>
          <label>Текст новости</label>
          <textarea rows={3} value={form.text} onChange={(e) => setForm({ ...form, text: e.target.value })} />
          <label className="row" style={{ alignItems: 'center', gap: 8 }}>
            <input
              type="checkbox"
              style={{ width: 'auto' }}
              checked={form.is_urgent}
              onChange={(e) => setForm({ ...form, is_urgent: e.target.checked })}
            />
            Urgent (отправить push)
          </label>
          {err && <div className="err">{err}</div>}
          <button style={{ marginTop: 12 }} disabled={busy}>
            {busy ? '…' : 'Опубликовать'}
          </button>
        </form>
      </div>

      <div className="card">
        <h2>Лента</h2>
        <table>
          <thead>
            <tr>
              <th>Источник</th>
              <th>Новость</th>
              <th>Влияние</th>
              <th>Время</th>
            </tr>
          </thead>
          <tbody>
            {posts.map((p) => (
              <tr key={p.id}>
                <td>
                  {p.source}
                  {p.is_urgent && <span className="tag red" style={{ marginLeft: 6 }}>urgent</span>}
                </td>
                <td style={{ maxWidth: 420 }}>{p.text}</td>
                <td>{impactTag(p.impact)}</td>
                <td className="muted">{new Date(p.published_at).toLocaleString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
