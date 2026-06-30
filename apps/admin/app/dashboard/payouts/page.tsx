'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Prov = {
  provider_id: string; user_id: string; name: string; avatar: string;
  signals_rev: number; courses_rev: number; earned: number; paid: number; available: number;
};
type Payout = { id: string; amount: number; currency: string; method: string | null; note: string | null; created_at: string };

const METHODS = [{ v: '', l: '—' }, { v: 'card', l: '💳 Карта' }, { v: 'crypto', l: '🪙 Крипто' }, { v: 'cash', l: '💵 Наличные' }];

export default function PayoutsPage() {
  const [list, setList] = useState<Prov[]>([]);
  const [sel, setSel] = useState<Prov | null>(null);
  const [history, setHistory] = useState<Payout[]>([]);
  const [err, setErr] = useState('');

  // Форма выплаты
  const [amount, setAmount] = useState('');
  const [method, setMethod] = useState('');
  const [note, setNote] = useState('');
  const [saving, setSaving] = useState(false);
  const [okMsg, setOkMsg] = useState('');

  const load = () => api<{ providers: Prov[] }>('/admin/payouts').then((r) => setList(r.providers)).catch((e) => setErr(e.message));
  useEffect(() => { load(); }, []);

  const select = async (p: Prov) => {
    setSel(p); setAmount(''); setMethod(''); setNote(''); setOkMsg('');
    const h = await api<{ payouts: Payout[] }>(`/admin/payouts/${p.user_id}`).catch(() => ({ payouts: [] as Payout[] }));
    setHistory(h.payouts);
  };

  const tg = (v: number) => `${Number(v ?? 0).toLocaleString('ru-RU')} ₸`;

  const pay = async () => {
    if (!sel) return;
    const amt = Number(amount);
    if (!amt || amt <= 0) return setErr('Укажите сумму выплаты');
    setSaving(true); setErr('');
    try {
      await api('/admin/payout', { method: 'POST', body: { user_id: sel.user_id, amount: amt, method: method || undefined, note: note || undefined } });
      setOkMsg(`Выплачено ${tg(amt)} трейдеру ${sel.name}`);
      setAmount(''); setNote('');
      await load();                                  // обновить балансы
      const h = await api<{ payouts: Payout[] }>(`/admin/payouts/${sel.user_id}`); // обновить историю
      setHistory(h.payouts);
      // Обновить выбранную карточку из свежего списка
      const fresh = (await api<{ providers: Prov[] }>('/admin/payouts')).providers.find((x) => x.user_id === sel.user_id);
      if (fresh) setSel(fresh);
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div>
      <h1>💸 Выплаты трейдерам</h1>
      <p className="muted">Заработок = продажи сигналов + курсов (₸). Остаток = заработано − выплачено. Фиксируйте перевод — он спишется с остатка и попадёт в историю трейдера.</p>
      {err && <div className="err">{err}</div>}
      {okMsg && <div className="card" style={{ borderLeft: '4px solid #059669', background: '#0596691a', marginTop: 10 }}>✅ {okMsg}</div>}

      <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: 16, marginTop: 16, alignItems: 'start' }}>
        {/* Список трейдеров */}
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
            <thead>
              <tr style={{ textAlign: 'left', color: 'var(--muted)' }}>
                <th style={th}>Трейдер</th><th style={th}>Заработано</th><th style={th}>Выплачено</th><th style={th}>Остаток</th>
              </tr>
            </thead>
            <tbody>
              {list.length === 0 && <tr><td colSpan={4} style={{ padding: 16, color: 'var(--muted)' }}>Нет трейдеров</td></tr>}
              {list.map((p) => (
                <tr
                  key={p.user_id}
                  onClick={() => select(p)}
                  style={{ borderTop: '1px solid var(--border)', cursor: 'pointer', background: sel?.user_id === p.user_id ? 'var(--accent)10' : undefined }}
                >
                  <td style={td}>{p.avatar} {p.name}</td>
                  <td style={td}>{tg(p.earned)}</td>
                  <td style={{ ...td, color: '#059669' }}>{tg(p.paid)}</td>
                  <td style={{ ...td, fontWeight: 800, color: p.available > 0 ? 'var(--gold)' : 'var(--muted)' }}>{tg(p.available)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Панель выплаты + история */}
        <div>
          {!sel ? (
            <div className="card muted" style={{ fontSize: 13 }}>← Выберите трейдера, чтобы зафиксировать выплату</div>
          ) : (
            <>
              <div className="card">
                <div style={{ fontWeight: 700, fontSize: 16, marginBottom: 4 }}>{sel.avatar} {sel.name}</div>
                <div style={{ display: 'flex', gap: 14, marginBottom: 12 }}>
                  <Stat label="Заработано" value={tg(sel.earned)} />
                  <Stat label="Выплачено" value={tg(sel.paid)} color="#059669" />
                  <Stat label="Остаток" value={tg(sel.available)} color="var(--gold)" />
                </div>
                <div className="muted" style={{ fontSize: 11, marginBottom: 8 }}>Сигналы {tg(sel.signals_rev)} · Курсы {tg(sel.courses_rev)}</div>
                <div style={{ display: 'grid', gap: 8 }}>
                  <input value={amount} onChange={(e) => setAmount(e.target.value)} inputMode="numeric" placeholder="Сумма выплаты, ₸" style={inp} />
                  <select value={method} onChange={(e) => setMethod(e.target.value)} style={inp}>
                    {METHODS.map((m) => <option key={m.v} value={m.v}>{m.l}</option>)}
                  </select>
                  <input value={note} onChange={(e) => setNote(e.target.value)} placeholder="Комментарий (напр. перевод на Kaspi)" style={inp} />
                  <button onClick={pay} disabled={saving} style={{ padding: '10px 16px', fontWeight: 700 }}>
                    {saving ? '…' : `Выплатить ${amount ? tg(Number(amount)) : ''}`}
                  </button>
                </div>
              </div>

              <div className="card" style={{ marginTop: 12, padding: 0, overflow: 'hidden' }}>
                <div className="muted" style={{ fontSize: 12, padding: '10px 14px', borderBottom: '1px solid var(--border)' }}>История выплат</div>
                {history.length === 0 ? (
                  <div style={{ padding: 14, color: 'var(--muted)', fontSize: 13 }}>Выплат пока не было</div>
                ) : history.map((h) => (
                  <div key={h.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 14px', borderTop: '1px solid var(--border)', fontSize: 13 }}>
                    <div>
                      <div style={{ fontWeight: 700 }}>{tg(h.amount)}</div>
                      <div className="muted" style={{ fontSize: 11 }}>{new Date(h.created_at).toLocaleString('ru-RU', { day: '2-digit', month: '2-digit', year: 'numeric' })}{h.method ? ` · ${h.method}` : ''}{h.note ? ` · ${h.note}` : ''}</div>
                    </div>
                    <span style={{ fontSize: 11, fontWeight: 700, color: '#059669', background: '#0596691a', padding: '3px 8px', borderRadius: 20 }}>Выплачено</span>
                  </div>
                ))}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

const th: React.CSSProperties = { padding: '10px 14px' };
const td: React.CSSProperties = { padding: '10px 14px' };
const inp: React.CSSProperties = { padding: '9px 11px', borderRadius: 8, border: '1px solid var(--border)', background: 'var(--bg)', color: 'var(--text)', fontSize: 13 };

function Stat({ label, value, color }: { label: string; value: string; color?: string }) {
  return (
    <div>
      <div className="muted" style={{ fontSize: 11 }}>{label}</div>
      <div style={{ fontSize: 17, fontWeight: 800, color: color ?? 'var(--text)' }}>{value}</div>
    </div>
  );
}
