'use client';

import { useCallback, useEffect, useState } from 'react';
import { api } from '@/lib/api';

type Loc = { ru?: string; kk?: string; en?: string };
type LocList = { ru?: string[]; kk?: string[]; en?: string[] };
type Category = 'book' | 'film' | 'podcast';

type Item = {
  id: string;
  category: Category;
  title: string;
  author: string;
  topic: string | null;
  year: number | null;
  rating: number | null;
  rating_max: number;
  rating_source: string | null;
  isbn: string | null;
  cover_url: string | null;
  youtube_id: string | null;
  external_url: string | null;
  lang: string | null;
  summary: Loc;
  ideas: LocList;
  conclusion: Loc | null;
  sort_order: number;
  is_published: boolean;
};

const CATS: { key: Category; label: string }[] = [
  { key: 'book', label: '📖 Книги' },
  { key: 'film', label: '🎬 Фильмы' },
  { key: 'podcast', label: '▶️ Подкасты' },
];

const LANGS: (keyof Loc)[] = ['ru', 'kk', 'en'];

function emptyForm(category: Category): Partial<Item> {
  return {
    category,
    title: '',
    author: '',
    topic: '',
    year: null,
    rating: null,
    rating_source: category === 'book' ? 'Goodreads' : category === 'film' ? 'IMDb' : null,
    isbn: '',
    cover_url: '',
    youtube_id: '',
    external_url: '',
    lang: category === 'podcast' ? 'EN' : null,
    summary: {},
    ideas: {},
    conclusion: {},
    sort_order: 0,
    is_published: true,
  };
}

export default function LibraryPage() {
  const [cat, setCat] = useState<Category>('book');
  const [items, setItems] = useState<Item[]>([]);
  const [err, setErr] = useState('');
  const [editing, setEditing] = useState<Partial<Item> | null>(null);
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    setErr('');
    try {
      const r = await api<{ items: Item[] }>(`/admin/library?category=${cat}`);
      setItems(r.items);
    } catch (e: any) {
      setErr(e.message);
    }
  }, [cat]);

  useEffect(() => {
    load();
  }, [load]);

  async function save() {
    if (!editing) return;
    setBusy(true);
    setErr('');
    try {
      const body: any = { ...editing };
      // бос локализация өрістерін тазалау
      const isNew = !editing.id;
      if (isNew) delete body.id;
      if (isNew) {
        await api('/admin/library', { method: 'POST', body });
      } else {
        await api(`/admin/library/${editing.id}`, { method: 'PATCH', body });
      }
      setEditing(null);
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
    }
  }

  async function del(it: Item) {
    if (!confirm(`Удалить «${it.title}»?`)) return;
    try {
      await api(`/admin/library/${it.id}`, { method: 'DELETE' });
      await load();
    } catch (e: any) {
      setErr(e.message);
    }
  }

  async function togglePublish(it: Item) {
    try {
      await api(`/admin/library/${it.id}`, { method: 'PATCH', body: { is_published: !it.is_published } });
      await load();
    } catch (e: any) {
      setErr(e.message);
    }
  }

  return (
    <div>
      <h1>Библиотека</h1>
      <p className="muted">Книги, фильмы и подкасты — приложение берёт этот каталог из базы через API.</p>
      {err && <div className="err">{err}</div>}

      <div className="row" style={{ margin: '14px 0' }}>
        {CATS.map((c) => (
          <button
            key={c.key}
            className={cat === c.key ? '' : 'ghost'}
            onClick={() => {
              setCat(c.key);
              setEditing(null);
            }}
          >
            {c.label}
          </button>
        ))}
        <button className="green" onClick={() => setEditing(emptyForm(cat))} style={{ marginLeft: 'auto' }}>
          + Добавить
        </button>
      </div>

      {editing && (
        <Editor
          value={editing}
          onChange={setEditing}
          onSave={save}
          onCancel={() => setEditing(null)}
          busy={busy}
        />
      )}

      <div className="card">
        <div className="muted" style={{ marginBottom: 8 }}>
          Всего: {items.length}
        </div>
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Название</th>
              <th>{cat === 'podcast' ? 'Канал' : 'Автор'}</th>
              <th>{cat === 'podcast' ? 'Язык' : 'Год'}</th>
              <th>★</th>
              <th>Тема</th>
              <th>Статус</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {items.map((it) => (
              <tr key={it.id}>
                <td className="muted">{it.sort_order}</td>
                <td>{it.title}</td>
                <td className="muted">{it.author}</td>
                <td>{cat === 'podcast' ? it.lang : it.year}</td>
                <td>{it.rating ?? '—'}</td>
                <td className="muted">{it.topic ?? '—'}</td>
                <td>
                  <button
                    className={it.is_published ? 'green' : 'ghost'}
                    onClick={() => togglePublish(it)}
                    style={{ padding: '4px 8px', fontSize: 12 }}
                  >
                    {it.is_published ? 'опубл.' : 'скрыт'}
                  </button>
                </td>
                <td>
                  <div className="row" style={{ gap: 6 }}>
                    <button className="ghost" style={{ padding: '4px 8px' }} onClick={() => setEditing(it)}>
                      ✎
                    </button>
                    <button className="danger" style={{ padding: '4px 8px' }} onClick={() => del(it)}>
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

function Editor({
  value,
  onChange,
  onSave,
  onCancel,
  busy,
}: {
  value: Partial<Item>;
  onChange: (v: Partial<Item>) => void;
  onSave: () => void;
  onCancel: () => void;
  busy: boolean;
}) {
  const cat = value.category as Category;
  const set = (patch: Partial<Item>) => onChange({ ...value, ...patch });
  const setLoc = (field: 'summary' | 'conclusion', lang: keyof Loc, v: string) =>
    set({ [field]: { ...(value[field] || {}), [lang]: v } } as Partial<Item>);
  const setIdeas = (lang: keyof Loc, v: string) =>
    set({ ideas: { ...(value.ideas || {}), [lang]: v.split('\n').map((s) => s.trim()).filter(Boolean) } });

  return (
    <div className="card" style={{ borderColor: 'var(--accent)' }}>
      <h2 style={{ marginTop: 0 }}>{value.id ? 'Редактировать' : 'Новый элемент'} · {cat}</h2>
      <div className="grid2">
        <label>
          Название
          <input value={value.title || ''} onChange={(e) => set({ title: e.target.value })} />
        </label>
        <label>
          {cat === 'podcast' ? 'Канал' : 'Автор / режиссёр'}
          <input value={value.author || ''} onChange={(e) => set({ author: e.target.value })} />
        </label>
        <label>
          Тема (topic)
          <input value={value.topic || ''} onChange={(e) => set({ topic: e.target.value })} />
        </label>
        {cat !== 'podcast' && (
          <label>
            Год
            <input
              type="number"
              value={value.year ?? ''}
              onChange={(e) => set({ year: e.target.value ? Number(e.target.value) : null })}
            />
          </label>
        )}
        {cat !== 'podcast' && (
          <label>
            Рейтинг (из {value.rating_max ?? 5})
            <input
              type="number"
              step="0.1"
              value={value.rating ?? ''}
              onChange={(e) => set({ rating: e.target.value ? Number(e.target.value) : null })}
            />
          </label>
        )}
        {cat === 'book' && (
          <label>
            ISBN (обложка)
            <input value={value.isbn || ''} onChange={(e) => set({ isbn: e.target.value })} />
          </label>
        )}
        {cat === 'podcast' && (
          <label>
            YouTube ID
            <input value={value.youtube_id || ''} onChange={(e) => set({ youtube_id: e.target.value })} />
          </label>
        )}
        {cat === 'podcast' && (
          <label>
            Язык
            <select value={value.lang || 'EN'} onChange={(e) => set({ lang: e.target.value })}>
              <option value="EN">EN</option>
              <option value="RU">RU</option>
            </select>
          </label>
        )}
        <label>
          Обложка URL (необяз.)
          <input value={value.cover_url || ''} onChange={(e) => set({ cover_url: e.target.value })} />
        </label>
        <label>
          Внешняя ссылка
          <input value={value.external_url || ''} onChange={(e) => set({ external_url: e.target.value })} />
        </label>
        <label>
          Порядок (sort)
          <input
            type="number"
            value={value.sort_order ?? 0}
            onChange={(e) => set({ sort_order: Number(e.target.value) })}
          />
        </label>
      </div>

      <h3>Описание (по языкам)</h3>
      {LANGS.map((lng) => (
        <label key={lng}>
          summary · {lng.toUpperCase()}
          <textarea
            rows={2}
            value={value.summary?.[lng] || ''}
            onChange={(e) => setLoc('summary', lng, e.target.value)}
          />
        </label>
      ))}

      {cat !== 'podcast' && (
        <>
          <h3>Главные идеи (по одной на строку)</h3>
          {LANGS.map((lng) => (
            <label key={lng}>
              ideas · {lng.toUpperCase()}
              <textarea
                rows={3}
                value={(value.ideas?.[lng] || []).join('\n')}
                onChange={(e) => setIdeas(lng, e.target.value)}
              />
            </label>
          ))}
        </>
      )}

      <label className="row" style={{ alignItems: 'center', gap: 8, marginTop: 10 }}>
        <input
          type="checkbox"
          checked={value.is_published ?? true}
          onChange={(e) => set({ is_published: e.target.checked })}
          style={{ width: 'auto' }}
        />
        Опубликовано (видно в приложении)
      </label>

      <div className="row" style={{ marginTop: 14 }}>
        <button onClick={onSave} disabled={busy}>
          {busy ? 'Сохраняю…' : 'Сохранить'}
        </button>
        <button className="ghost" onClick={onCancel}>
          Отмена
        </button>
      </div>
    </div>
  );
}
