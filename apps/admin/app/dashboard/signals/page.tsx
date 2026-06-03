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
};
type Provider = { id: string; name: string };

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
  const [form, setForm] = useState({ ...empty });
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);

  async function load() {
    try {
      const [s, p] = await Promise.all([
        api<{ signals: Signal[] }>('/signals'),
        api<{ providers: Provider[] }>('/providers'),
      ]);
      setSignals(s.signals);
      setProviders(p.providers);
    } catch (e: any) {
      setErr(e.message);
    }
  }
  useEffect(() => {
    load();
  }, []);

  function num(v: string) {
    return v === '' ? undefined : Number(v);
  }

  async function create(e: React.FormEvent) {
    e.preventDefault();
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
          rr: num(form.rr),
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
              <input value={form.tp3} onChange={(e) => setForm({ ...form, tp3: e.target.value })} />
            </div>
          </div>
          <div className="grid2">
            <div>
              <label>RR</label>
              <input value={form.rr} onChange={(e) => setForm({ ...form, rr: e.target.value })} />
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
                <td>
                  {s.status === 'active' && (
                    <div className="row">
                      <button className="green" onClick={() => close(s.id, 'closed_tp1')}>
                        TP
                      </button>
                      <button className="danger" onClick={() => close(s.id, 'closed_sl')}>
                        SL
                      </button>
                    </div>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
