'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Signal = {
  id: string;
  pair: string;
  direction: string;
  entry_from: number;
  entry_to: number;
  sl: number;
  rr: number;
  confidence: number;
  status: string;
  result_pips?: number;
  votes?: Record<string, number>;
};
type Provider = { id: string; name: string };
type DeletedSignal = {
  id: string; pair: string; direction: string; status: string; result_pips?: number; rr: number;
  deleted_at: string; published_at: string; provider_name: string | null;
  author_name: string | null; author_phone: string | null;
};

const empty = {
  direction: 'buy',
  entry_from: '',
  entry_to: '',
  tp1: '',
  tp2: '',
  tp3: '',
  sl: '',
  rr: '',
  confidence: '70',
  analysis: '',
  provider_id: '',
};

export default function SignalsPage() {
  const [signals, setSignals] = useState<Signal[]>([]);
  const [providers, setProviders] = useState<Provider[]>([]);
  const [deleted, setDeleted] = useState<DeletedSignal[]>([]);
  const [showDeleted, setShowDeleted] = useState(false);
  const [form, setForm] = useState({ ...empty });
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);

  async function load() {
    try {
      const [s, p, d] = await Promise.all([
        api<{ signals: Signal[] }>('/signals'),
        api<{ providers: Provider[] }>('/providers'),
        api<{ signals: DeletedSignal[] }>('/admin/signals/deleted').catch(() => ({ signals: [] as DeletedSignal[] })),
      ]);
      setSignals(s.signals);
      setProviders(p.providers);
      setDeleted(d.signals);
    } catch (e: any) {
      setErr(e.message);
    }
  }

  async function restore(id: string) {
    setBusy(true);
    setErr('');
    try {
      await api(`/admin/signals/${id}/restore`, { method: 'POST' });
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
    }
  }
  useEffect(() => {
    load();
  }, []);

  function num(v: string) {
    if (v == null || v.trim() === '') return undefined;
    const n = Number(v);
    return Number.isNaN(n) ? undefined : n;
  }

  // RR: "1:3" → 3, "3" → 3, бос/жарамсыз → undefined
  function parseRr(v: string) {
    const t = (v ?? '').trim();
    if (!t) return undefined;
    const m = t.match(/^1\s*:\s*([\d.]+)$/);
    const n = m ? Number(m[1]) : Number(t);
    return Number.isNaN(n) ? undefined : n;
  }

  async function create(e: React.FormEvent) {
    e.preventDefault();
    const need: [string, string][] = [
      ['Entry от', form.entry_from],
      ['Entry до', form.entry_to],
      ['TP1', form.tp1],
      ['SL', form.sl],
      ['RR', form.rr],
      ['Анализ', form.analysis],
    ];
    const missing = need.filter(([, v]) => !String(v).trim()).map(([k]) => k);
    if (missing.length) {
      setErr('Заполните обязательные поля: ' + missing.join(', '));
      return;
    }
    setBusy(true);
    setErr('');
    try {
      await api('/signals', {
        method: 'POST',
        body: {
          pair: 'XAU/USD',
          direction: form.direction,
          entry_from: num(form.entry_from),
          entry_to: num(form.entry_to),
          tp1: num(form.tp1),
          tp2: num(form.tp2),
          tp3: num(form.tp3),
          sl: num(form.sl),
          rr: parseRr(form.rr),
          confidence: num(form.confidence),
          analysis: form.analysis,
          provider_id: form.provider_id || undefined,
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

  async function close(id: string, status: string) {
    const pips = prompt('Результат в пунктах (например 120 или -60):');
    if (pips === null) return;
    try {
      await api(`/signals/${id}/close`, { method: 'POST', body: { status, result_pips: Number(pips) } });
      await load();
    } catch (e: any) {
      setErr(e.message);
    }
  }

  async function del(id: string) {
    if (!confirm('Удалить идею? Это действие необратимо.')) return;
    try {
      await api(`/signals/${id}`, { method: 'DELETE' });
      await load();
    } catch (e: any) {
      setErr(e.message);
    }
  }

  function votesLabel(v?: Record<string, number>): string {
    if (!v) return '';
    const parts = (['tp1', 'tp2', 'tp3', 'sl'] as const).filter((k) => v[k]).map((k) => `${k.toUpperCase()}:${v[k]}`);
    return parts.join(' ');
  }

  return (
    <div>
      <h1>Сигналы / Идеи</h1>
      {err && <div className="err">{err}</div>}

      <div className="card">
        <h2>Опубликовать идею</h2>
        <form onSubmit={create}>
          <div className="grid2">
            <div>
              <label>Направление</label>
              <select value={form.direction} onChange={(e) => setForm({ ...form, direction: e.target.value })}>
                <option value="buy">BUY</option>
                <option value="sell">SELL</option>
              </select>
            </div>
            <div>
              <label>Провайдер</label>
              <select value={form.provider_id} onChange={(e) => setForm({ ...form, provider_id: e.target.value })}>
                <option value="">— без провайдера —</option>
                {providers.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name}
                  </option>
                ))}
              </select>
            </div>
          </div>
          <div className="grid2">
            <div>
              <label>Entry от</label>
              <input value={form.entry_from} onChange={(e) => setForm({ ...form, entry_from: e.target.value })} />
            </div>
            <div>
              <label>Entry до</label>
              <input value={form.entry_to} onChange={(e) => setForm({ ...form, entry_to: e.target.value })} />
            </div>
          </div>
          <div className="grid2">
            <div>
              <label>TP1</label>
              <input value={form.tp1} onChange={(e) => setForm({ ...form, tp1: e.target.value })} />
            </div>
            <div>
              <label>SL</label>
              <input value={form.sl} onChange={(e) => setForm({ ...form, sl: e.target.value })} />
            </div>
          </div>
          <div className="grid2">
            <div>
              <label>TP2 (опц.)</label>
              <input value={form.tp2} onChange={(e) => setForm({ ...form, tp2: e.target.value })} />
            </div>
            <div>
              <label>TP3 (опц.)</label>
              <input placeholder="число или пусто" value={form.tp3} onChange={(e) => setForm({ ...form, tp3: e.target.value })} />
            </div>
          </div>
          <div className="grid2">
            <div>
              <label>RR</label>
              <input placeholder="напр. 3 или 1:3" value={form.rr} onChange={(e) => setForm({ ...form, rr: e.target.value })} />
            </div>
            <div>
              <label>Уверенность %</label>
              <input value={form.confidence} onChange={(e) => setForm({ ...form, confidence: e.target.value })} />
            </div>
          </div>
          <label>Анализ</label>
          <textarea rows={3} value={form.analysis} onChange={(e) => setForm({ ...form, analysis: e.target.value })} />
          <button style={{ marginTop: 12 }} disabled={busy}>
            {busy ? 'Публикация…' : 'Опубликовать'}
          </button>
        </form>
      </div>

      <div className="card">
        <h2>Лента</h2>
        <table>
          <thead>
            <tr>
              <th>Напр.</th>
              <th>Entry</th>
              <th>SL</th>
              <th>RR</th>
              <th>Статус</th>
              <th>Голоса 👥</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {signals.map((s) => (
              <tr key={s.id}>
                <td>
                  <span className={`tag ${s.direction === 'buy' ? 'green' : 'red'}`}>{s.direction.toUpperCase()}</span>
                </td>
                <td>
                  {s.entry_from}–{s.entry_to}
                </td>
                <td>{s.sl}</td>
                <td>1:{Number(s.rr).toFixed(1)}</td>
                <td>
                  <span className="tag gold">{s.status}</span>
                  {s.result_pips != null && <span className="muted"> {s.result_pips}p</span>}
                </td>
                <td className="muted" style={{ fontSize: 12 }}>
                  {votesLabel(s.votes)}
                </td>
                <td>
                  <div className="row" style={{ gap: 6 }}>
                    {s.status === 'active' && (
                      <>
                        <button className="green" onClick={() => close(s.id, 'closed_tp1')}>
                          TP
                        </button>
                        <button className="danger" onClick={() => close(s.id, 'closed_sl')}>
                          SL
                        </button>
                      </>
                    )}
                    <button className="ghost" style={{ padding: '4px 8px' }} onClick={() => del(s.id)}>
                      🗑️
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* 🗑 Удалённые (аудит) — анти-фрод: что удалено, не теряется из статистики */}
      <div className="card" style={{ marginTop: 16 }}>
        <div className="row" style={{ alignItems: 'center', justifyContent: 'space-between' }}>
          <h2 style={{ margin: 0 }}>🗑 Удалённые идеи · аудит ({deleted.length})</h2>
          <button className="ghost" onClick={() => setShowDeleted((v) => !v)}>
            {showDeleted ? 'Скрыть' : 'Показать'}
          </button>
        </div>
        <p className="muted" style={{ fontSize: 12, marginTop: 6 }}>
          Удалённые идеи скрыты из приложения, но остаются в базе и в статистике провайдера
          (нельзя «удалить» убыточную идею, чтобы поднять Win Rate). Можно восстановить.
        </p>
        {showDeleted &&
          (deleted.length === 0 ? (
            <p className="muted">Удалённых идей нет.</p>
          ) : (
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
              <thead>
                <tr style={{ textAlign: 'left', color: 'var(--muted)' }}>
                  <th style={{ padding: '8px 10px' }}>Пара / Направл.</th>
                  <th style={{ padding: '8px 10px' }}>Статус</th>
                  <th style={{ padding: '8px 10px' }}>Результат</th>
                  <th style={{ padding: '8px 10px' }}>Провайдер / Автор</th>
                  <th style={{ padding: '8px 10px' }}>Удалено</th>
                  <th style={{ padding: '8px 10px' }}></th>
                </tr>
              </thead>
              <tbody>
                {deleted.map((s) => (
                  <tr key={s.id} style={{ borderTop: '1px solid var(--border)' }}>
                    <td style={{ padding: '8px 10px' }}>
                      <b>{s.pair}</b> · {s.direction === 'buy' ? 'BUY' : 'SELL'}
                    </td>
                    <td style={{ padding: '8px 10px' }}>
                      <span
                        className="badge"
                        style={{
                          background: s.status === 'closed_sl' ? '#dc2626' : s.status.startsWith('closed_tp') ? '#059669' : '#555',
                          color: '#fff',
                        }}
                      >
                        {s.status}
                      </span>
                    </td>
                    <td style={{ padding: '8px 10px', fontWeight: 700, color: (s.result_pips ?? 0) >= 0 ? '#059669' : '#dc2626' }}>
                      {s.result_pips != null ? `${s.result_pips > 0 ? '+' : ''}${s.result_pips} pips` : '—'}
                    </td>
                    <td style={{ padding: '8px 10px' }}>
                      {s.provider_name || s.author_name || '—'}
                      {s.author_phone ? <span className="muted"> · {s.author_phone}</span> : null}
                    </td>
                    <td style={{ padding: '8px 10px' }} className="muted">
                      {new Date(s.deleted_at).toLocaleString('ru-RU')}
                    </td>
                    <td style={{ padding: '8px 10px' }}>
                      <button className="ghost" disabled={busy} onClick={() => restore(s.id)}>
                        ♻ Восстановить
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          ))}
      </div>
    </div>
  );
}
