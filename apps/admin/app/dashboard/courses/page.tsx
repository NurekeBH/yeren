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
  cover_url: string | null;
  sort_order: number;
  is_published: boolean;
  module_count: number;
  kind: string | null; // 'video' | null (curriculum)
};

type VModule = { title: string; video: string; text: string };
type VForm = {
  id?: string;
  title: string;
  subtitle: string;
  description: string;
  cover_url: string;
  price_bonus: number;
  emoji: string;
  intro_video: string;
  modules: VModule[];
  is_published: boolean;
};

const emptyForm = (): VForm => ({
  title: '',
  subtitle: '',
  description: '',
  cover_url: '',
  price_bonus: 0,
  emoji: '🎬',
  intro_video: '',
  modules: [{ title: '', video: '', text: '' }],
  is_published: true,
});

const LANGS: (keyof Loc)[] = ['ru', 'kk', 'en'];

export default function CoursesPage() {
  const [items, setItems] = useState<Course[]>([]);
  const [err, setErr] = useState('');
  const [form, setForm] = useState<VForm | null>(null);
  const [meta, setMeta] = useState<Course | null>(null); // curriculum курс метадатасы (3-тіл)
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

  async function editCourse(c: Course) {
    setErr('');
    // Curriculum курс (КОД РЫНКА) — контентін бұзбау үшін тек метадата (3-тіл) өңделеді.
    if (c.kind !== 'video') {
      setMeta(c);
      return;
    }
    try {
      const r = await api<{ course: any }>(`/admin/courses/${c.id}`);
      const co = r.course;
      const content = co.content || {};
      setForm({
        id: co.id,
        title: co.title?.ru ?? '',
        subtitle: co.subtitle?.ru ?? '',
        description: co.description?.ru ?? '',
        cover_url: co.cover_url ?? '',
        price_bonus: co.price_bonus ?? 0,
        emoji: co.emoji ?? '🎬',
        intro_video: content.intro_video ?? '',
        modules:
          Array.isArray(content.modules) && content.kind === 'video'
            ? content.modules.map((m: any) => ({ title: m.title ?? '', video: m.video ?? '', text: m.text ?? '' }))
            : [{ title: '', video: '', text: '' }],
        is_published: co.is_published,
      });
    } catch (e: any) {
      setErr(e.message);
    }
  }

  async function save() {
    if (!form) return;
    setBusy(true);
    setErr('');
    try {
      await api('/admin/courses', { method: 'POST', body: form });
      setForm(null);
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
    }
  }

  async function saveMeta() {
    if (!meta) return;
    setBusy(true);
    setErr('');
    try {
      await api(`/admin/courses/${meta.id}`, {
        method: 'PATCH',
        body: {
          title: meta.title,
          subtitle: meta.subtitle,
          description: meta.description,
          price_bonus: meta.price_bonus,
          is_published: meta.is_published,
        },
      });
      setMeta(null);
      await load();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
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

  const set = (patch: Partial<VForm>) => setForm((f) => (f ? { ...f, ...patch } : f));
  const setModule = (i: number, patch: Partial<VModule>) =>
    setForm((f) => (f ? { ...f, modules: f.modules.map((m, j) => (j === i ? { ...m, ...patch } : m)) } : f));

  return (
    <div>
      <div className="row" style={{ alignItems: 'center', justifyContent: 'space-between' }}>
        <h1>Курсы</h1>
        <button className="green" onClick={() => setForm(emptyForm())}>
          + Добавить курс
        </button>
      </div>
      <p className="muted">Видео-курсы: обложка, модули с видео и текстом, бесплатное вступительное видео. Пользователи покупают/смотрят в приложении.</p>
      {err && <div className="err">{err}</div>}

      {form && (
        <div className="card" style={{ borderColor: 'var(--accent)' }}>
          <h2 style={{ marginTop: 0 }}>{form.id ? 'Редактировать курс' : 'Новый видео-курс'}</h2>
          <div className="grid2">
            <label>
              Название курса
              <input value={form.title} onChange={(e) => set({ title: e.target.value })} />
            </label>
            <label>
              Подзаголовок
              <input value={form.subtitle} onChange={(e) => set({ subtitle: e.target.value })} />
            </label>
          </div>
          <label>
            Описание
            <textarea rows={2} value={form.description} onChange={(e) => set({ description: e.target.value })} />
          </label>
          <div className="grid2">
            <label>
              Обложка (URL картинки, необяз.)
              <input value={form.cover_url} onChange={(e) => set({ cover_url: e.target.value })} placeholder="https://… или оставь пусто (превью intro-видео)" />
            </label>
            <label>
              Бесплатное вступительное видео (URL)
              <input value={form.intro_video} onChange={(e) => set({ intro_video: e.target.value })} placeholder="https://youtube.com/watch?v=…" />
            </label>
            <label>
              Цена (бонус ₸, 0 = бесплатно)
              <input type="number" value={form.price_bonus} onChange={(e) => set({ price_bonus: Number(e.target.value) })} />
            </label>
            <label>
              Эмодзи
              <input value={form.emoji} onChange={(e) => set({ emoji: e.target.value })} />
            </label>
          </div>

          <h3>Модули</h3>
          {form.modules.map((m, i) => (
            <div key={i} className="card" style={{ background: 'var(--bg)' }}>
              <div className="row" style={{ justifyContent: 'space-between', alignItems: 'center' }}>
                <strong>Модуль {i + 1}</strong>
                <button
                  className="danger"
                  style={{ padding: '4px 8px' }}
                  onClick={() => set({ modules: form.modules.filter((_, j) => j !== i) })}
                >
                  ✕
                </button>
              </div>
              <label>
                Название модуля
                <input value={m.title} onChange={(e) => setModule(i, { title: e.target.value })} />
              </label>
              <label>
                Ссылка на видео
                <input value={m.video} onChange={(e) => setModule(i, { video: e.target.value })} placeholder="https://youtube.com/watch?v=…" />
              </label>
              <label>
                Текст / описание модуля
                <textarea rows={2} value={m.text} onChange={(e) => setModule(i, { text: e.target.value })} />
              </label>
            </div>
          ))}
          <button className="ghost" onClick={() => set({ modules: [...form.modules, { title: '', video: '', text: '' }] })}>
            + Добавить модуль
          </button>

          <label className="row" style={{ alignItems: 'center', gap: 8, marginTop: 14 }}>
            <input type="checkbox" checked={form.is_published} onChange={(e) => set({ is_published: e.target.checked })} style={{ width: 'auto' }} />
            Опубликован (виден в приложении)
          </label>

          <div className="row" style={{ marginTop: 14 }}>
            <button onClick={save} disabled={busy}>
              {busy ? 'Сохраняю…' : 'Сохранить курс'}
            </button>
            <button className="ghost" onClick={() => setForm(null)}>
              Отмена
            </button>
          </div>
        </div>
      )}

      {meta && (
        <div className="card" style={{ borderColor: 'var(--accent)' }}>
          <h2 style={{ marginTop: 0 }}>Курс (метаданные) · {meta.id}</h2>
          {LANGS.map((lng) => (
            <div key={lng} style={{ marginBottom: 10 }}>
              <label>
                Название · {lng.toUpperCase()}
                <input value={meta.title?.[lng] || ''} onChange={(e) => setMeta({ ...meta, title: { ...meta.title, [lng]: e.target.value } })} />
              </label>
              <label>
                Подзаголовок · {lng.toUpperCase()}
                <input value={meta.subtitle?.[lng] || ''} onChange={(e) => setMeta({ ...meta, subtitle: { ...meta.subtitle, [lng]: e.target.value } })} />
              </label>
              <label>
                Описание · {lng.toUpperCase()}
                <textarea rows={2} value={meta.description?.[lng] || ''} onChange={(e) => setMeta({ ...meta, description: { ...meta.description, [lng]: e.target.value } })} />
              </label>
            </div>
          ))}
          <label>
            Цена (бонус ₸, 0 = бесплатно)
            <input type="number" value={meta.price_bonus} onChange={(e) => setMeta({ ...meta, price_bonus: Number(e.target.value) })} />
          </label>
          <label className="row" style={{ alignItems: 'center', gap: 8, marginTop: 10 }}>
            <input type="checkbox" checked={meta.is_published} onChange={(e) => setMeta({ ...meta, is_published: e.target.checked })} style={{ width: 'auto' }} />
            Опубликован
          </label>
          <div className="row" style={{ marginTop: 14 }}>
            <button onClick={saveMeta} disabled={busy}>
              {busy ? 'Сохраняю…' : 'Сохранить'}
            </button>
            <button className="ghost" onClick={() => setMeta(null)}>
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
              <th>Тип</th>
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
                <td className="muted">{c.kind === 'video' ? '🎬 видео' : '📚 курс'}</td>
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
                  <button className="ghost" style={{ padding: '4px 10px' }} onClick={() => editCourse(c)}>
                    ✎ Изменить
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
