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
  app.get('/courses/catalog', async (req) => {
    const lang = (req.query as { lang?: string }).lang || 'ru';
    const { rows } = await query(
      `select id, title, subtitle, description, price_bonus, emoji, accent, sort_order,
              coalesce(content -> $1, content -> 'ru') as content
         from course_catalog where is_published = true order by sort_order`,
      [lang],
    );
    return { courses: rows };
  });

  // ── Админ: курстар тізімі (метадата; content көлемі үлкен болғандықтан мұнда қайтарылмайды) ──
  app.get('/admin/courses', { onRequest: [app.requireAdmin] }, async () => {
    const { rows } = await query(
      `select id, title, subtitle, description, price_bonus, emoji, accent, sort_order, is_published,
              jsonb_array_length(coalesce(content -> 'ru' -> 'modules', '[]'::jsonb)) as module_count,
              created_at, updated_at
         from course_catalog order by sort_order`,
    );
    return { courses: rows };
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
