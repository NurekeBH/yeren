import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query, tx } from '../../db/client.js';

/// Академия курстары: сатып алу (бонуспен), прогресс (өтілген сабақтар),
/// финалдық емтихан нәтижелері. Барлық бонус қозғалысы bonus_transactions-қа жазылады.
// Админ курс метадатасы (толық ағаш seed-тен келеді; админ метадата/баға/жариялауды басқарады).
const CourseMetaBody = z.object({
  title: z.record(z.string()).optional(),
  subtitle: z.record(z.string()).optional(),
  description: z.record(z.string()).optional(),
  price_bonus: z.number().int().min(0).optional(),
  emoji: z.string().optional(),
  accent: z.number().int().optional(),
  sort_order: z.number().int().optional(),
  is_published: z.boolean().optional(),
});
const COURSE_META_JSONB = new Set(['title', 'subtitle', 'description']);

export async function coursesRoutes(app: FastifyInstance) {
  // ── Каталог (қоғамдық): жарияланған курстар, content таңдалған тілде ──
  // curriculum курстарда content={ru,kk,en}; видео-курстарда content={kind:'video',...}
  // (тіл кілті жоқ) → соңғы fallback бүкіл content-ті қайтарады.
  app.get('/courses/catalog', async (req) => {
    const lang = (req.query as { lang?: string }).lang || 'ru';
    const { rows } = await query(
      `select id, title, subtitle, description, price_bonus, emoji, accent, cover_url, sort_order,
              coalesce(content -> $1, content -> 'ru', content) as content
         from course_catalog where is_published = true order by sort_order`,
      [lang],
    );
    return { courses: rows };
  });

  // ── Админ: курстар тізімі (метадата + kind + модуль/сабақ саны) ──
  app.get('/admin/courses', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query(
      `select id, title, subtitle, description, price_bonus, emoji, accent, cover_url, sort_order, is_published,
              content ->> 'kind' as kind,
              coalesce(jsonb_array_length(content -> 'ru' -> 'modules'),
                       jsonb_array_length(content -> 'modules'), 0) as module_count,
              case when jsonb_typeof(content -> 'modules') = 'array'
                   then coalesce((select sum(jsonb_array_length(m -> 'lessons'))::int
                                    from jsonb_array_elements(content -> 'modules') m), 0)
                   else 0 end as lesson_count,
              created_at, updated_at
         from course_catalog order by sort_order`,
    );
    return { courses: rows };
  });

  // ── Админ: бір курстың толық деректері (видео-курс өңдеуге) ──
  app.get('/admin/courses/:id', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query<{ content: Record<string, unknown> } & Record<string, unknown>>(
      'select id, title, subtitle, description, price_bonus, emoji, cover_url, is_published, sort_order, content from course_catalog where id = $1',
      [id],
    );
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    return { course: rows[0] };
  });

  // ── Админ: видео-курс МЕТАДАТАСЫ (құру/жаңарту). Сабақтар бөлек (PUT .../lessons). ──
  // Екі қадам: (1) курс құру/өңдеу (атау, subname опц., мұқаба, сипаттама опц.),
  //            (2) тізімнен сол курсқа сабақ қосу. Бір курс — көп сабақ (модульсіз).
  const VideoMeta = z.object({
    id: z.string().optional(),
    title: z.string().min(1),
    subtitle: z.string().optional().default(''),
    description: z.string().optional().default(''),
    cover_url: z.string().nullish(),
    price_bonus: z.number().int().min(0).default(0),
    emoji: z.string().optional().default('🎬'),
    intro_video: z.string().nullish(),
    is_published: z.boolean().default(true),
  });

  app.post('/admin/courses', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const parsed = VideoMeta.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;
    const wrap = (s?: string) => JSON.stringify(s ? { ru: s } : {});
    const intro = JSON.stringify(d.intro_video ?? null);

    if (d.id) {
      // Бар курс — тек метадата жаңарту; сабақтар (content.modules) ӨЗГЕРМЕЙДІ, intro ғана мерж.
      const { rows } = await query<{ id: string }>(
        `update course_catalog set
            title=$2, subtitle=$3, description=$4, price_bonus=$5, emoji=$6, cover_url=$7, is_published=$8,
            content = jsonb_set(coalesce(content, '{"kind":"video","modules":[]}'::jsonb), '{intro_video}', $9::jsonb, true),
            updated_at = now()
          where id=$1 returning id`,
        [d.id, wrap(d.title), wrap(d.subtitle), wrap(d.description), d.price_bonus, d.emoji, d.cover_url ?? null,
         d.is_published, intro],
      );
      if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
      return { id: rows[0].id };
    }

    // Жаңа курс — бос сабақ тізімімен (сабақтар кейін қосылады).
    const id = `vc-${Date.now()}`;
    const content = { kind: 'video', intro_video: d.intro_video ?? null, modules: [{ title: '', lessons: [] }] };
    const { rows } = await query<{ id: string }>(
      `insert into course_catalog (id, title, subtitle, description, price_bonus, emoji, cover_url, content, is_published)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9) returning id`,
      [id, wrap(d.title), wrap(d.subtitle), wrap(d.description), d.price_bonus, d.emoji, d.cover_url ?? null,
       JSON.stringify(content), d.is_published],
    );
    return { id: rows[0].id };
  });

  // ── Админ: курстың САБАҚТАРЫН орнату (жалаң тізім — бір атаусыз модульде сақталады) ──
  const LessonsBody = z.object({
    lessons: z
      .array(
        z.object({
          title: z.string().default(''),
          video: z.string().optional().default(''),
          text: z.string().optional().default(''),
        }),
      )
      .default([]),
  });

  app.put('/admin/courses/:id/lessons', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = LessonsBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const modules = JSON.stringify([{ title: '', lessons: parsed.data.lessons }]);
    // kind='video' + бар intro_video сақталады; modules ауыстырылады.
    const { rows } = await query<{ id: string }>(
      `update course_catalog set
          content = jsonb_build_object(
            'kind', 'video',
            'intro_video', coalesce(content -> 'intro_video', 'null'::jsonb),
            'modules', $2::jsonb),
          updated_at = now()
        where id=$1 returning id`,
      [id, modules],
    );
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    return { id: rows[0].id };
  });

  // ── Админ: курс метадатасын өзгерту (баға/эмодзи/жариялау/реттік т.б.) ──
  app.patch('/admin/courses/:id', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = CourseMetaBody.partial().safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const set: string[] = [];
    const args: unknown[] = [id];
    for (const [k, v] of Object.entries(parsed.data)) {
      if (v === undefined) continue;
      const j = COURSE_META_JSONB.has(k);
      args.push(j ? JSON.stringify(v) : v);
      set.push(`${k} = $${args.length}${j ? '::jsonb' : ''}`);
    }
    if (set.length === 0) return { ok: true };
    set.push('updated_at = now()');
    const { rows } = await query(
      `update course_catalog set ${set.join(', ')} where id = $1
       returning id, title, subtitle, description, price_bonus, emoji, accent, sort_order, is_published`,
      args,
    );
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    return { course: rows[0] };
  });

  // ── Админ: курсты жою ──
  app.delete('/admin/courses/:id', { onRequest: [app.requireAdmin] }, async (req) => {
    await query('delete from course_catalog where id = $1', [(req.params as { id: string }).id]);
    return { ok: true };
  });

  // ════════════ ПРОВАЙДЕР ПАНЕЛІ (расталған трейдер — тек ӨЗ курстары) ════════════
  // Провайдер курс құрады → is_published=false (админ жариялағанша app-та көрінбейді).
  const ownerGuard = async (id: string, userId: string): Promise<boolean> => {
    const { rows } = await query<{ owner_id: string | null }>('select owner_id from course_catalog where id = $1', [id]);
    return rows[0]?.owner_id === userId;
  };

  app.get('/provider/courses', { onRequest: [app.requireTrader] }, async (req) => {
    const { rows } = await query(
      `select c.id, c.title, c.subtitle, c.description, c.price_bonus, c.emoji, c.cover_url, c.is_published,
              c.content ->> 'kind' as kind,
              case when jsonb_typeof(c.content -> 'modules') = 'array'
                   then coalesce((select sum(jsonb_array_length(m -> 'lessons'))::int
                                    from jsonb_array_elements(c.content -> 'modules') m), 0)
                   else 0 end as lesson_count,
              (select count(*) from course_purchases p where p.course_id = c.id)::int as buyers,
              (select coalesce(sum(p.bonus_used),0) from course_purchases p where p.course_id = c.id)::int as revenue
         from course_catalog c where c.owner_id = $1 order by c.created_at desc`,
      [req.userId],
    );
    return { courses: rows };
  });

  app.get('/provider/courses/:id', { onRequest: [app.requireTrader] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    if (!(await ownerGuard(id, req.userId!))) return reply.code(403).send({ error: 'not_owner' });
    const { rows } = await query(
      'select id, title, subtitle, description, price_bonus, emoji, cover_url, is_published, content from course_catalog where id = $1',
      [id],
    );
    return { course: rows[0] };
  });

  app.post('/provider/courses', { onRequest: [app.requireTrader] }, async (req, reply) => {
    const parsed = VideoMeta.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;
    const wrap = (s?: string) => JSON.stringify(s ? { ru: s } : {});
    const intro = JSON.stringify(d.intro_video ?? null);

    if (d.id) {
      if (!(await ownerGuard(d.id, req.userId!))) return reply.code(403).send({ error: 'not_owner' });
      // Провайдер метадатаны жаңартады; жариялау (is_published) — АДМИН құзыреті, қозғамаймыз.
      const { rows } = await query<{ id: string }>(
        `update course_catalog set
            title=$2, subtitle=$3, description=$4, price_bonus=$5, emoji=$6, cover_url=$7,
            content = jsonb_set(coalesce(content, '{"kind":"video","modules":[]}'::jsonb), '{intro_video}', $8::jsonb, true),
            updated_at = now()
          where id=$1 and owner_id=$9 returning id`,
        [d.id, wrap(d.title), wrap(d.subtitle), wrap(d.description), d.price_bonus, d.emoji, d.cover_url ?? null, intro, req.userId],
      );
      if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
      return { id: rows[0].id };
    }

    // Жаңа курс — иесі провайдер, is_published=false (админ растағанша app-та жоқ).
    const id = `vc-${Date.now()}`;
    const content = { kind: 'video', intro_video: d.intro_video ?? null, modules: [{ title: '', lessons: [] }] };
    const { rows } = await query<{ id: string }>(
      `insert into course_catalog (id, title, subtitle, description, price_bonus, emoji, cover_url, content, is_published, owner_id)
       values ($1,$2,$3,$4,$5,$6,$7,$8,false,$9) returning id`,
      [id, wrap(d.title), wrap(d.subtitle), wrap(d.description), d.price_bonus, d.emoji, d.cover_url ?? null, JSON.stringify(content), req.userId],
    );
    return { id: rows[0].id, pending: true };
  });

  app.put('/provider/courses/:id/lessons', { onRequest: [app.requireTrader] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    if (!(await ownerGuard(id, req.userId!))) return reply.code(403).send({ error: 'not_owner' });
    const parsed = LessonsBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const modules = JSON.stringify([{ title: '', lessons: parsed.data.lessons }]);
    await query(
      `update course_catalog set
          content = jsonb_build_object('kind','video','intro_video', coalesce(content -> 'intro_video','null'::jsonb), 'modules', $2::jsonb),
          updated_at = now()
        where id=$1 and owner_id=$3`,
      [id, modules, req.userId],
    );
    return { ok: true };
  });

  // ── Сатып алынған курстар ──
  app.get('/courses/me', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query<{ course_id: string; bonus_used: number; created_at: string }>(
      'select course_id, bonus_used, created_at from course_purchases where user_id = $1',
      [req.userId],
    );
    return { purchases: rows };
  });

  // ── Курсты бонуспен ашу (идемпотент) ──
  app.post('/courses/:id/purchase', { onRequest: [app.authenticate] }, async (req, reply) => {
    const courseId = (req.params as { id: string }).id;
    const parsed = z.object({ bonus_cost: z.number().int().min(0) }).safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const cost = parsed.data.bonus_cost;

    const exists = await query('select 1 from course_purchases where user_id = $1 and course_id = $2', [
      req.userId,
      courseId,
    ]);
    if (exists.rowCount) return { ok: true, already: true };

    try {
      const balance = await tx(async (c) => {
        const u = await c.query<{ bonus_balance: number }>(
          'select bonus_balance from users where id = $1 for update',
          [req.userId],
        );
        const bal = u.rows[0]?.bonus_balance ?? 0;
        if (bal < cost) throw new Error('insufficient');
        await c.query('update users set bonus_balance = bonus_balance - $1 where id = $2', [cost, req.userId]);
        await c.query(
          'insert into course_purchases (user_id, course_id, bonus_used) values ($1, $2, $3)',
          [req.userId, courseId, cost],
        );
        await c.query(
          "insert into bonus_transactions (user_id, type, amount, ref) values ($1, 'spend_course', $2, $3)",
          [req.userId, -cost, `course:${courseId}`],
        );
        return bal - cost;
      });
      return { ok: true, bonus_balance: balance };
    } catch {
      return reply.code(400).send({ error: 'insufficient_bonus' });
    }
  });

  // ── Курс прогресі (өтілген сабақтар) ──
  app.get('/courses/:id/progress', { onRequest: [app.authenticate] }, async (req) => {
    const courseId = (req.params as { id: string }).id;
    const { rows } = await query<{ lesson_id: string }>(
      'select lesson_id from course_progress where user_id = $1 and course_id = $2',
      [req.userId, courseId],
    );
    return { completed: rows.map((r) => r.lesson_id) };
  });

  // ── Сабақты «өтілді» деп белгілеу ──
  app.post('/courses/:id/lessons/:lessonId/complete', { onRequest: [app.authenticate] }, async (req) => {
    const { id, lessonId } = req.params as { id: string; lessonId: string };
    await query(
      `insert into course_progress (user_id, course_id, lesson_id) values ($1, $2, $3)
       on conflict (user_id, course_id, lesson_id) do nothing`,
      [req.userId, id, lessonId],
    );
    return { ok: true };
  });

  // ── Финалдық емтихан нәтижесін сақтау ──
  app.post('/courses/:id/exam', { onRequest: [app.authenticate] }, async (req, reply) => {
    const courseId = (req.params as { id: string }).id;
    const parsed = z
      .object({
        score: z.number().int().min(0),
        total: z.number().int().min(1),
        passed: z.boolean(),
        per_module: z.record(z.string(), z.object({ correct: z.number().int(), total: z.number().int() })).optional(),
      })
      .safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });
    const { score, total, passed } = parsed.data;
    const perModule = parsed.data.per_module ?? {};
    const { rows } = await query<{ id: string }>(
      `insert into exam_results (user_id, course_id, score, total, passed, per_module)
       values ($1, $2, $3, $4, $5, $6) returning id`,
      [req.userId, courseId, score, total, passed, JSON.stringify(perModule)],
    );
    return { ok: true, id: rows[0]?.id };
  });

  // ── Соңғы емтихан нәтижесі ──
  app.get('/courses/:id/exam', { onRequest: [app.authenticate] }, async (req) => {
    const courseId = (req.params as { id: string }).id;
    const { rows } = await query(
      `select score, total, passed, per_module, created_at
         from exam_results where user_id = $1 and course_id = $2
        order by created_at desc limit 1`,
      [req.userId, courseId],
    );
    return { result: rows[0] ?? null };
  });
}
