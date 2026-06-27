import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query, tx } from '../../db/client.js';

const TestSubmit = z.object({
  profile_type: z.enum(['revenge', 'uncontrolled_risk', 'hope', 'disciplined']),
  scores: z.record(z.string(), z.number()),
});

const Complete = z.object({
  quick_check_answer: z.string().max(2000).optional(),
});

export async function academyRoutes(app: FastifyInstance) {
  // ── Психология сабақтары каталогы v2 (DB-ден, локализацияланған {ru,kk,en}) ──
  app.get('/academy/lessons', async (req) => {
    const profile = (req.query as { profile_type?: string }).profile_type ?? null;
    const { rows } = await query(
      `select id, profile_type, source_type, source_name, tag, xp, external_url,
              title, quote, explanation, gold_application, quick_check, sort_order
         from academy_lessons
        where is_published = true and ($1::text is null or profile_type = $1)
        order by sort_order, id`,
      [profile],
    );
    return { lessons: rows };
  });

  // ── Gallup тест сұрақтары (трейдер профилін анықтау) ──
  app.get('/academy/questions', async () => {
    const { rows } = await query(
      'select id, text, options, sort_order from gallup_questions order by sort_order, id',
    );
    return { questions: rows };
  });

  app.get('/lessons', async (req) => {
    const Q = z.object({ profile_type: z.string().optional() });
    const { profile_type } = Q.parse(req.query);
    const sql = profile_type
      ? 'select * from lessons where profile_type = $1 order by generated_at desc'
      : 'select * from lessons order by generated_at desc';
    const { rows } = await query(sql, profile_type ? [profile_type] : []);
    return { lessons: rows };
  });

  app.get('/lessons/:id', async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rows } = await query('select * from lessons where id = $1', [id]);
    if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
    return { lesson: rows[0] };
  });

  app.post('/lessons/:id/complete', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = Complete.safeParse(req.body ?? {});
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request' });

    const result = await tx(async (c) => {
      const lesson = await c.query<{ xp: number }>('select xp from lessons where id = $1', [id]);
      if (lesson.rows.length === 0) return null;
      await c.query(
        `insert into user_lesson_progress (user_id, lesson_id, quick_check_answer)
         values ($1, $2, $3)
         on conflict (user_id, lesson_id)
         do update set quick_check_answer = excluded.quick_check_answer, completed_at = now()`,
        [req.userId, id, parsed.data.quick_check_answer ?? null],
      );
      const xp = lesson.rows[0]!.xp;
      const today = new Date();
      const dow = (today.getUTCDay() + 6) % 7; // Mon = 0
      const week = Array.from({ length: 7 }, (_, i) => i === dow);
      const upd = await c.query<{ xp: number; streak: number; week_progress: boolean[] }>(
        `insert into user_progress (user_id, xp, streak, last_completed, week_progress)
         values ($1, $2, 1, current_date, $3::boolean[])
         on conflict (user_id) do update set
           xp = user_progress.xp + excluded.xp,
           streak = case
             when user_progress.last_completed = current_date then user_progress.streak
             when user_progress.last_completed = current_date - interval '1 day' then user_progress.streak + 1
             else 1 end,
           last_completed = current_date,
           week_progress[$4] = true
         returning xp, streak, week_progress`,
        [req.userId, xp, week, dow + 1], // Postgres массив индексі 1-ден басталады
      );
      return upd.rows[0];
    });

    if (!result) return reply.code(404).send({ error: 'not_found' });
    return result;
  });

  // Gallup тест нәтижесін сақтау (TZ §11.2)
  app.post('/academy/test', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = TestSubmit.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const { profile_type, scores } = parsed.data;
    const { rows } = await query(
      `insert into user_test_results (user_id, profile_type, scores)
       values ($1, $2, $3::jsonb) returning *`,
      [req.userId, profile_type, JSON.stringify(scores)],
    );
    return { result: rows[0] };
  });

  app.get('/academy/test/latest', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      `select * from user_test_results where user_id = $1 order by taken_at desc limit 1`,
      [req.userId],
    );
    return { result: rows[0] ?? null };
  });

  app.get('/academy/progress', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      `select xp, streak, last_completed, week_progress from user_progress where user_id = $1`,
      [req.userId],
    );
    return { progress: rows[0] ?? { xp: 0, streak: 0, week_progress: [false, false, false, false, false, false, false] } };
  });
}
