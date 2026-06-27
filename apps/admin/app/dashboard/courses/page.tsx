'use client';

import { useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Loc = { ru?: string; kk?: string; en?: string };
type Course = {
  id: string;
  title: Loc;
  subtitle: Loc;
  description: Loc;
  price_bonus: number;
  emoji: string;
  accent: number;
  sort_order: number;
  is_published: boolean;
  module_count: number;
};

const LANGS: (keyof Loc)[] = ['ru', 'kk', 'en'];

export default function CoursesPage() {
  const [items, setItems] = useState<Course[]>([]);
  const [err, setErr] = useState('');
  const [editing, setEditing] = useState<Course | null>(null);
  const [busy, setBusy] = useState(false);

  async function load() {
    setErr('');
    try {
      const r = await api<{ courses: Course[] }>('/admin/courses');
      setItems(r.courses);
    } catch (e: any) {
      setErr(e.message);
    }
  }
  useEffect(() => {
    load();
  }, []);

  async function save() {
    if (!editing) return;
    setBusy(true);
    setErr('');
    try {
      await api(`/admin/courses/${editing.id}`, {
        method: 'PATCH',
        body: {
          title: editing.title,
          subtitle: editing.subtitle,
          description: editing.description,
          price_bonus: editing.price_bonus,
          emoji: editing.emoji,
          accent: editing.accent,
          sort_order: editing.sort_order,
          is_published: editing.is_published,
        },
      });
      setEditing(null);
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
    }
  }

  async function del(c: Course) {
    if (!confirm(`Удалить курс «${c.title.ru || c.id}»? Контент тоже удалится.`)) return;
    try {
      await api(`/admin/courses/${c.id}`, { method: 'DELETE' });
      await load();
    } catch (e: any) {
      setErr(e.message);
    }
  }

  async function togglePublish(c: Course) {
    try {
      await api(`/admin/courses/${c.id}`, { method: 'PATCH', body: { is_published: !c.is_published } });
      await load();
    } catch (e: any) {
      setErr(e.message);
    }
  }

  return (
    <div>
      <h1>Курсы</h1>
      <p className="muted">
        Контент курсов (модули → уроки → тесты) хранится в базе как JSONB; приложение берёт его через API.
        Здесь — метаданные, цена и публикация.
      </p>
      {err && <div className="err">{err}</div>}

      {editing && (
        <div className="card" style={{ borderColor: 'var(--accent)' }}>
          <h2 style={{ marginTop: 0 }}>Курс · {editing.id}</h2>
          {LANGS.map((lng) => (
            <div key={lng} style={{ marginBottom: 10 }}>
              <label>
                Название · {lng.toUpperCase()}
                <input
                  value={editing.title?.[lng] || ''}
                  onChange={(e) => setEditing({ ...editing, title: { ...editing.title, [lng]: e.target.value } })}
                />
              </label>
              <label>
                Подзаголовок · {lng.toUpperCase()}
                <input
                  value={editing.subtitle?.[lng] || ''}
                  onChange={(e) =>
                    setEditing({ ...editing, subtitle: { ...editing.subtitle, [lng]: e.target.value } })
                  }
                />
              </label>
              <label>
                Описание · {lng.toUpperCase()}
                <textarea
                  rows={2}
                  value={editing.description?.[lng] || ''}
                  onChange={(e) =>
                    setEditing({ ...editing, description: { ...editing.description, [lng]: e.target.value } })
                  }
                />
              </label>
            </div>
          ))}
          <div className="grid2">
            <label>
              Цена (бонус ₸, 0 = бесплатно)
              <input
                type="number"
                value={editing.price_bonus}
                onChange={(e) => setEditing({ ...editing, price_bonus: Number(e.target.value) })}
              />
            </label>
            <label>
              Эмодзи
              <input value={editing.emoji} onChange={(e) => setEditing({ ...editing, emoji: e.target.value })} />
            </label>
            <label>
              Порядок (sort)
              <input
                type="number"
                value={editing.sort_order}
                onChange={(e) => setEditing({ ...editing, sort_order: Number(e.target.value) })}
              />
            </label>
          </div>
          <label className="row" style={{ alignItems: 'center', gap: 8, marginTop: 10 }}>
            <input
              type="checkbox"
              checked={editing.is_published}
              onChange={(e) => setEditing({ ...editing, is_published: e.target.checked })}
              style={{ width: 'auto' }}
            />
            Опубликован
          </label>
          <div className="row" style={{ marginTop: 14 }}>
            <button onClick={save} disabled={busy}>
              {busy ? 'Сохраняю…' : 'Сохранить'}
            </button>
            <button className="ghost" onClick={() => setEditing(null)}>
              Отмена
            </button>
          </div>
        </div>
      )}

      <div className="card">
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Курс</th>
              <th>Модулей</th>
              <th>Цена</th>
              <th>Статус</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {items.map((c) => (
              <tr key={c.id}>
                <td className="muted">{c.sort_order}</td>
                <td>
                  {c.emoji} {c.title?.ru || c.id}
                </td>
                <td>{c.module_count}</td>
                <td>{c.price_bonus > 0 ? `${c.price_bonus} ₸` : 'free'}</td>
                <td>
                  <button
                    className={c.is_published ? 'green' : 'ghost'}
                    onClick={() => togglePublish(c)}
                    style={{ padding: '4px 8px', fontSize: 12 }}
                  >
                    {c.is_published ? 'опубл.' : 'скрыт'}
                  </button>
                </td>
                <td>
                  <div className="row" style={{ gap: 6 }}>
                    <button className="ghost" style={{ padding: '4px 8px' }} onClick={() => setEditing(c)}>
                      ✎
                    </button>
                    <button className="danger" style={{ padding: '4px 8px' }} onClick={() => del(c)}>
                      ✕
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
