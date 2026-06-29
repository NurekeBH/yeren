'use client';

import { useEffect, useState } from 'react';
import { api, uploadImage } from '@/lib/api';

type Course = {
  id: string;
  title: { ru?: string };
  price_bonus: number;
  emoji: string;
  cover_url: string | null;
  is_published: boolean;
  lesson_count: number;
  buyers: number;
  revenue: number;
};

type VLesson = { title: string; video: string; text: string };
type MetaForm = {
  id?: string;
  title: string; subtitle: string; description: string;
  cover_url: string; price_bonus: number; emoji: string; intro_video: string;
};
type LessonsPanel = { id: string; title: string; lessons: VLesson[] };

const emptyMeta = (): MetaForm => ({ title: '', subtitle: '', description: '', cover_url: '', price_bonus: 0, emoji: '🎬', intro_video: '' });
const emptyLesson = (): VLesson => ({ title: '', video: '', text: '' });

function flatten(content: any): VLesson[] {
  const mods = Array.isArray(content?.modules) ? content.modules : [];
  const out: VLesson[] = [];
  for (const m of mods) for (const ls of m?.lessons ?? []) out.push({ title: ls.title ?? '', video: ls.video ?? '', text: ls.text ?? '' });
  return out;
}

export default function ProviderCoursesPage() {
  const [items, setItems] = useState<Course[]>([]);
  const [form, setForm] = useState<MetaForm | null>(null);
  const [lessons, setLessons] = useState<LessonsPanel | null>(null);
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);
  const [uploading, setUploading] = useState(false);

  async function load() {
    try {
      const r = await api<{ courses: Course[] }>('/provider/courses');
      setItems(r.courses);
    } catch (e: any) { setErr(e.message); }
  }
  useEffect(() => { load(); }, []);

  async function onCover(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file || !form) return;
    setUploading(true); setErr('');
    try {
      const url = await uploadImage(file);
      setForm((f) => (f ? { ...f, cover_url: url } : f));
    } catch (e: any) { setErr(e.message); } finally { setUploading(false); }
  }

  async function edit(c: Course) {
    setErr('');
    try {
      const r = await api<{ course: any }>(`/provider/courses/${c.id}`);
      const co = r.course;
      setForm({
        id: co.id, title: co.title?.ru ?? '', subtitle: co.subtitle?.ru ?? '', description: co.description?.ru ?? '',
        cover_url: co.cover_url ?? '', price_bonus: co.price_bonus ?? 0, emoji: co.emoji ?? '🎬',
        intro_video: co.content?.intro_video ?? '',
      });
    } catch (e: any) { setErr(e.message); }
  }

  async function saveCourse() {
    if (!form) return;
    setBusy(true); setErr('');
    const isNew = !form.id;
    try {
      const r = await api<{ id: string }>('/provider/courses', { method: 'POST', body: form });
      setForm(null);
      await load();
      if (isNew && r?.id) await openLessons(r.id);
    } catch (e: any) { setErr(e.message); } finally { setBusy(false); }
  }

  async function openLessons(id: string) {
    setErr('');
    try {
      const r = await api<{ course: any }>(`/provider/courses/${id}`);
      const co = r.course;
      setLessons({ id, title: co.title?.ru || id, lessons: flatten(co.content) });
    } catch (e: any) { setErr(e.message); }
  }

  async function saveLessons() {
    if (!lessons) return;
    setBusy(true); setErr('');
    try {
      await api(`/provider/courses/${lessons.id}/lessons`, { method: 'PUT', body: { lessons: lessons.lessons } });
      setLessons(null);
      await load();
    } catch (e: any) { setErr(e.message); } finally { setBusy(false); }
  }

  const set = (p: Partial<MetaForm>) => setForm((f) => (f ? { ...f, ...p } : f));
  const setLesson = (i: number, p: Partial<VLesson>) =>
    setLessons((s) => (s ? { ...s, lessons: s.lessons.map((ls, k) => (k === i ? { ...ls, ...p } : ls)) } : s));

  return (
    <div>
      <div className="row" style={{ alignItems: 'center', justifyContent: 'space-between' }}>
        <h1>Мои курсы</h1>
        <button className="green" onClick={() => setForm(emptyMeta())}>+ Добавить курс</button>
      </div>
      <p className="muted">
        Шаг 1 — создайте курс. Шаг 2 — добавьте уроки. После создания курс уходит на проверку администратору — он появится в приложении после одобрения (публикации).
      </p>
      {err && <div className="err">{err}</div>}

      {/* 1-қадам: метадата */}
      {form && (
        <div className="card" style={{ borderColor: 'var(--accent)' }}>
          <h2 style={{ marginTop: 0 }}>{form.id ? 'Редактировать курс' : 'Новый курс'}</h2>
          <div className="grid2">
            <label>Название курса<input value={form.title} onChange={(e) => set({ title: e.target.value })} /></label>
            <label>Подзаголовок <span className="muted" style={{ fontSize: 12 }}>(необязательно)</span>
              <input value={form.subtitle} onChange={(e) => set({ subtitle: e.target.value })} /></label>
          </div>
          <label>Описание <span className="muted" style={{ fontSize: 12 }}>(необязательно)</span>
            <textarea rows={2} value={form.description} onChange={(e) => set({ description: e.target.value })} /></label>
          <div className="grid2">
            <label>Обложка (фото)
              <input type="file" accept="image/*" onChange={onCover} disabled={uploading} />
              {uploading && <span className="muted"> загрузка…</span>}
              <span className="muted" style={{ fontSize: 12, display: 'block', marginTop: 4 }}>Рекомендуется 1200×675 px (16:9), до 5 МБ.</span>
              {form.cover_url && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={form.cover_url} alt="" style={{ display: 'block', maxWidth: 240, borderRadius: 8, marginTop: 8 }} />
              )}
            </label>
            <label>Бесплатное вступительное видео (URL, необяз.)
              <input value={form.intro_video} onChange={(e) => set({ intro_video: e.target.value })} placeholder="https://youtube.com/watch?v=…" /></label>
            <label>Цена (бонус ₸, 0 = бесплатно)
              <input type="number" value={form.price_bonus} onChange={(e) => set({ price_bonus: Number(e.target.value) })} /></label>
            <label>Эмодзи<input value={form.emoji} onChange={(e) => set({ emoji: e.target.value })} /></label>
          </div>
          <div className="row" style={{ marginTop: 14 }}>
            <button onClick={saveCourse} disabled={busy}>{busy ? 'Сохраняю…' : form.id ? 'Сохранить' : 'Создать и добавить уроки →'}</button>
            <button className="ghost" onClick={() => setForm(null)}>Отмена</button>
          </div>
        </div>
      )}

      {/* 2-қадам: сабақтар */}
      {lessons && (
        <div className="card" style={{ borderColor: 'var(--accent)' }}>
          <h2 style={{ marginTop: 0 }}>Уроки · {lessons.title}</h2>
          {lessons.lessons.map((ls, i) => (
            <div key={i} className="card" style={{ background: 'var(--bg)' }}>
              <div className="row" style={{ justifyContent: 'space-between', alignItems: 'center' }}>
                <span className="muted">▶️ Урок {i + 1}</span>
                <button className="danger" style={{ padding: '2px 8px' }} onClick={() => setLessons((s) => (s ? { ...s, lessons: s.lessons.filter((_, k) => k !== i) } : s))}>✕</button>
              </div>
              <label>Название урока<input value={ls.title} onChange={(e) => setLesson(i, { title: e.target.value })} /></label>
              <label>Ссылка на видео<input value={ls.video} onChange={(e) => setLesson(i, { video: e.target.value })} placeholder="https://youtube.com/watch?v=…" /></label>
              <label>Текст урока<textarea rows={2} value={ls.text} onChange={(e) => setLesson(i, { text: e.target.value })} /></label>
            </div>
          ))}
          {lessons.lessons.length === 0 && <p className="muted">Пока нет уроков.</p>}
          <button className="ghost" onClick={() => setLessons((s) => (s ? { ...s, lessons: [...s.lessons, emptyLesson()] } : s))}>+ Добавить урок</button>
          <div className="row" style={{ marginTop: 14 }}>
            <button onClick={saveLessons} disabled={busy}>{busy ? 'Сохраняю…' : 'Сохранить уроки'}</button>
            <button className="ghost" onClick={() => setLessons(null)}>Закрыть</button>
          </div>
        </div>
      )}

      {/* Қысқаша аналитика */}
      {items.length > 0 && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14, marginBottom: 16 }}>
          <div className="card">
            <div className="muted" style={{ fontSize: 12 }}>Куплено всего</div>
            <div style={{ fontSize: 26, fontWeight: 800, color: 'var(--gold)' }}>{items.reduce((s, c) => s + (c.buyers || 0), 0)}</div>
          </div>
          <div className="card">
            <div className="muted" style={{ fontSize: 12 }}>Выручка (бонусы)</div>
            <div style={{ fontSize: 26, fontWeight: 800, color: '#059669' }}>{items.reduce((s, c) => s + (c.revenue || 0), 0).toLocaleString('ru-RU')} ₸</div>
          </div>
          <div className="card">
            <div className="muted" style={{ fontSize: 12 }}>Курсов</div>
            <div style={{ fontSize: 26, fontWeight: 800 }}>{items.length}</div>
          </div>
        </div>
      )}

      <div className="card">
        <table>
          <thead><tr><th>Курс</th><th>Уроков</th><th>Цена</th><th>Куплено</th><th>Выручка</th><th>Статус</th><th></th></tr></thead>
          <tbody>
            {items.length === 0 && <tr><td colSpan={7} className="muted">Курсов пока нет</td></tr>}
            {items.map((c) => (
              <tr key={c.id}>
                <td>{c.emoji} {c.title?.ru || c.id}</td>
                <td>{c.lesson_count}</td>
                <td>{c.price_bonus > 0 ? `${c.price_bonus} ₸` : 'free'}</td>
                <td style={{ fontWeight: 700 }}>{c.buyers ?? 0}</td>
                <td>{(c.revenue ?? 0).toLocaleString('ru-RU')} ₸</td>
                <td>
                  {c.is_published
                    ? <span style={{ color: '#059669', fontWeight: 700, fontSize: 12 }}>✓ опубликован</span>
                    : <span style={{ color: '#D97706', fontWeight: 700, fontSize: 12 }}>⏳ на проверке</span>}
                </td>
                <td>
                  <div className="row" style={{ gap: 6 }}>
                    <button className="ghost" style={{ padding: '4px 10px' }} onClick={() => openLessons(c.id)}>▶️ Уроки</button>
                    <button className="ghost" style={{ padding: '4px 10px' }} onClick={() => edit(c)}>✎ Изменить</button>
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
