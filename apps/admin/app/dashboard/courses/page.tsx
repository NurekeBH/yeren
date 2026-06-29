'use client';

import { useEffect, useState } from 'react';
import { api, uploadImage } from '@/lib/api';

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
  lesson_count: number;
  kind: string | null; // 'video' | null (curriculum)
};

type VLesson = { title: string; video: string; text: string };

// Курс метадатасы (1-қадам: атау, subname опц., мұқаба, сипаттама опц.)
type MetaForm = {
  id?: string;
  title: string;
  subtitle: string;
  description: string;
  cover_url: string;
  price_bonus: number;
  emoji: string;
  intro_video: string;
  is_published: boolean;
};

// Сабақтар панелі (2-қадам: тізімнен курсқа сабақ қосу)
type LessonsPanel = { course: Course; lessons: VLesson[] };

const emptyMeta = (): MetaForm => ({
  title: '',
  subtitle: '',
  description: '',
  cover_url: '',
  price_bonus: 0,
  emoji: '🎬',
  intro_video: '',
  is_published: true,
});

const emptyLesson = (): VLesson => ({ title: '', video: '', text: '' });
const LANGS: (keyof Loc)[] = ['ru', 'kk', 'en'];

// content.modules → жалаң сабақ тізімі (модуль атаулары еленбейді — UI модульсіз).
function flattenLessons(content: any): VLesson[] {
  const mods = Array.isArray(content?.modules) ? content.modules : [];
  const out: VLesson[] = [];
  for (const m of mods) {
    for (const ls of m?.lessons ?? []) {
      out.push({ title: ls.title ?? '', video: ls.video ?? '', text: ls.text ?? '' });
    }
  }
  return out;
}

export default function CoursesPage() {
  const [items, setItems] = useState<Course[]>([]);
  const [err, setErr] = useState('');
  const [form, setForm] = useState<MetaForm | null>(null); // видео-курс метадатасы
  const [meta, setMeta] = useState<Course | null>(null); // curriculum курс метадатасы (3-тіл)
  const [lessons, setLessons] = useState<LessonsPanel | null>(null); // сабақтар редакторы
  const [busy, setBusy] = useState(false);
  const [uploading, setUploading] = useState(false);

  async function onCoverFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file || !form) return;
    setUploading(true);
    setErr('');
    try {
      const url = await uploadImage(file);
      setForm((f) => (f ? { ...f, cover_url: url } : f));
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setUploading(false);
    }
  }

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

  // Курс метадатасын өңдеуге ашу (видео-курс). Curriculum болса — 3-тіл метадата панелі.
  async function editCourse(c: Course) {
    setErr('');
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
        is_published: co.is_published,
      });
    } catch (e: any) {
      setErr(e.message);
    }
  }

  // 1-қадам: курс метадатасын сақтау. Жаңа курс болса → бірден сабақтар панелін ашамыз.
  async function saveCourse() {
    if (!form) return;
    setBusy(true);
    setErr('');
    const isNew = !form.id;
    try {
      const r = await api<{ id: string }>('/admin/courses', { method: 'POST', body: form });
      setForm(null);
      await load();
      if (isNew && r?.id) await openLessons(r.id);
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setBusy(false);
    }
  }

  // 2-қадам: курстың сабақтарын ашу (id бойынша).
  async function openLessons(id: string) {
    setErr('');
    try {
      const r = await api<{ course: any }>(`/admin/courses/${id}`);
      const co = r.course;
      setLessons({
        course: { ...co, title: co.title, kind: co.content?.kind ?? null } as Course,
        lessons: flattenLessons(co.content),
      });
    } catch (e: any) {
      setErr(e.message);
    }
  }

  async function saveLessons() {
    if (!lessons) return;
    setBusy(true);
    setErr('');
    try {
      await api(`/admin/courses/${lessons.course.id}/lessons`, { method: 'PUT', body: { lessons: lessons.lessons } });
      setLessons(null);
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

  const set = (patch: Partial<MetaForm>) => setForm((f) => (f ? { ...f, ...patch } : f));
  const setLesson = (li: number, patch: Partial<VLesson>) =>
    setLessons((p) => (p ? { ...p, lessons: p.lessons.map((ls, k) => (k === li ? { ...ls, ...patch } : ls)) } : p));

  return (
    <div>
      <div className="row" style={{ alignItems: 'center', justifyContent: 'space-between' }}>
        <h1>Курсы</h1>
        <button className="green" onClick={() => setForm(emptyMeta())}>
          + Добавить курс
        </button>
      </div>
      <p className="muted">
        Шаг 1 — создайте курс (название, обложка, описание). Шаг 2 — в списке нажмите «Уроки» и добавьте уроки. Один курс — много уроков.
      </p>
      {err && <div className="err">{err}</div>}

      {/* ── 1-ҚАДАМ: курс метадатасы ── */}
      {form && (
        <div className="card" style={{ borderColor: 'var(--accent)' }}>
          <h2 style={{ marginTop: 0 }}>{form.id ? 'Редактировать курс' : 'Новый курс'}</h2>
          <div className="grid2">
            <label>
              Название курса
              <input value={form.title} onChange={(e) => set({ title: e.target.value })} placeholder="напр. Основы XAU/USD" />
            </label>
            <label>
              Подзаголовок <span className="muted" style={{ fontSize: 12 }}>(необязательно)</span>
              <input value={form.subtitle} onChange={(e) => set({ subtitle: e.target.value })} placeholder="короткий слоган" />
            </label>
          </div>
          <label>
            Описание <span className="muted" style={{ fontSize: 12 }}>(необязательно)</span>
            <textarea rows={2} value={form.description} onChange={(e) => set({ description: e.target.value })} />
          </label>
          <div className="grid2">
            <label>
              Обложка курса (фото)
              <input type="file" accept="image/*" onChange={onCoverFile} disabled={uploading} />
              {uploading && <span className="muted"> загрузка…</span>}
              <span className="muted" style={{ fontSize: 12, display: 'block', marginTop: 4 }}>
                Рекомендуемый размер: 1200×675 px (16:9), до 5 МБ. Пусто → превью intro-видео.
              </span>
              {form.cover_url && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={form.cover_url} alt="" style={{ display: 'block', maxWidth: 240, borderRadius: 8, marginTop: 8 }} />
              )}
            </label>
            <label>
              Бесплатное вступительное видео (URL, необяз.)
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

          <label className="row" style={{ alignItems: 'center', gap: 8, marginTop: 14 }}>
            <input type="checkbox" checked={form.is_published} onChange={(e) => set({ is_published: e.target.checked })} style={{ width: 'auto' }} />
            Опубликован (виден в приложении)
          </label>

          <div className="row" style={{ marginTop: 14 }}>
            <button onClick={saveCourse} disabled={busy}>
              {busy ? 'Сохраняю…' : form.id ? 'Сохранить' : 'Создать курс и добавить уроки →'}
            </button>
            <button className="ghost" onClick={() => setForm(null)}>
              Отмена
            </button>
          </div>
        </div>
      )}

      {/* ── 2-ҚАДАМ: сабақтар редакторы ── */}
      {lessons && (
        <div className="card" style={{ borderColor: 'var(--accent)' }}>
          <h2 style={{ marginTop: 0 }}>
            Уроки · {lessons.course.emoji} {lessons.course.title?.ru || lessons.course.id}
          </h2>
          <p className="muted" style={{ marginTop: 0 }}>Один курс — несколько уроков. Каждый урок: название, видео, текст.</p>

          {lessons.lessons.map((ls, li) => (
            <div key={li} className="card" style={{ background: 'var(--bg)' }}>
              <div className="row" style={{ justifyContent: 'space-between', alignItems: 'center' }}>
                <span className="muted">▶️ Урок {li + 1}</span>
                <button
                  className="danger"
                  style={{ padding: '2px 8px' }}
                  onClick={() => setLessons((p) => (p ? { ...p, lessons: p.lessons.filter((_, k) => k !== li) } : p))}
                >
                  ✕
                </button>
              </div>
              <label>
                Название урока
                <input value={ls.title} onChange={(e) => setLesson(li, { title: e.target.value })} />
              </label>
              <label>
                Ссылка на видео
                <input value={ls.video} onChange={(e) => setLesson(li, { video: e.target.value })} placeholder="https://youtube.com/watch?v=…" />
              </label>
              <label>
                Текст урока
                <textarea rows={2} value={ls.text} onChange={(e) => setLesson(li, { text: e.target.value })} />
              </label>
            </div>
          ))}
          {lessons.lessons.length === 0 && <p className="muted">Пока нет уроков. Нажмите «+ Добавить урок».</p>}

          <button className="ghost" onClick={() => setLessons((p) => (p ? { ...p, lessons: [...p.lessons, emptyLesson()] } : p))}>
            + Добавить урок
          </button>

          <div className="row" style={{ marginTop: 14 }}>
            <button onClick={saveLessons} disabled={busy}>
              {busy ? 'Сохраняю…' : 'Сохранить уроки'}
            </button>
            <button className="ghost" onClick={() => setLessons(null)}>
              Закрыть
            </button>
          </div>
        </div>
      )}

      {/* ── Curriculum (КОД РЫНКА) метадатасы (3-тіл) ── */}
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
              <th>Уроков</th>
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
                <td>{c.kind === 'video' ? c.lesson_count : c.module_count}</td>
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
                    {c.kind === 'video' && (
                      <button className="ghost" style={{ padding: '4px 10px' }} onClick={() => openLessons(c.id)}>
                        ▶️ Уроки
                      </button>
                    )}
                    <button className="ghost" style={{ padding: '4px 10px' }} onClick={() => editCourse(c)}>
                      ✎ Изменить
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
