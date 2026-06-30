import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';
import { getOrSet, invalidatePrefix } from '../../utils/cache.js';

// Кітапхана каталогы (Кітап/Фильм/Подкаст) енді DB-де (library_items), админ басқарады.
// Серверде пайдаланушы деректері де бар: сақтау / рейтинг / отзыв (library_user_data).
const UpsertBody = z.object({
  saved: z.boolean().optional(),
  rating: z.number().int().min(0).max(5).optional(),
  review: z.string().optional(),
});

// Каталог элементі (админ CRUD). Локализацияланатын мәтін {ru,kk,en} картасы.
const LibItemBody = z.object({
  id: z.string().min(1).optional(), // болмаса авто-генерация
  category: z.enum(['book', 'film', 'podcast']),
  title: z.string().min(1),
  author: z.string().optional(),
  topic: z.string().nullish(),
  year: z.number().int().nullish(),
  rating: z.number().nullish(),
  rating_max: z.number().optional(),
  rating_source: z.string().nullish(),
  isbn: z.string().nullish(),
  cover_url: z.string().nullish(),
  youtube_id: z.string().nullish(),
  external_url: z.string().nullish(),
  lang: z.string().nullish(),
  summary: z.record(z.string()).optional(),
  ideas: z.record(z.array(z.string())).optional(),
  conclusion: z.record(z.string()).nullish(),
  sort_order: z.number().int().optional(),
  is_published: z.boolean().optional(),
});
const LIB_JSONB = new Set(['summary', 'ideas', 'conclusion']);
const LIB_COLS =
  'id, category, title, author, topic, year, rating, rating_max, rating_source, isbn, cover_url, youtube_id, external_url, lang, summary, ideas, conclusion, sort_order, is_published';

export async function libraryRoutes(app: FastifyInstance) {
  // Пайдаланушының барлық кітапхана деректері (сақталғандар, бағалар, отзывтар)
  app.get('/library/me', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query(
      'select item_id, saved, rating, review from library_user_data where user_id = $1',
      [req.userId],
    );
    return { items: rows };
  });

  // Сақтау / рейтинг / отзыв (upsert)
  app.put('/library/:itemId', { onRequest: [app.authenticate] }, async (req, reply) => {
    const itemId = (req.params as { itemId: string }).itemId;
    const parsed = UpsertBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;

    const set: string[] = [];
    const args: unknown[] = [req.userId, itemId];
    for (const [k, v] of Object.entries(d)) {
      if (v === undefined) continue;
      args.push(v);
      set.push(`${k} = $${args.length}`);
    }
    if (set.length === 0) return { ok: true };
    set.push('updated_at = now()');

    await query(
      `insert into library_user_data (user_id, item_id) values ($1, $2) on conflict do nothing`,
      [req.userId, itemId],
    );
    await query(
      `update library_user_data set ${set.join(', ')} where user_id = $1 and item_id = $2`,
      args,
    );
    return { ok: true };
  });

  // Бір элементтің барлық отзывтары (қоғамдық)
  app.get('/library/:itemId/reviews', async (req) => {
    const itemId = (req.params as { itemId: string }).itemId;
    const { rows } = await query(
      `select u.name, d.rating, d.review, d.updated_at
         from library_user_data d join users u on u.id = d.user_id
        where d.item_id = $1 and (d.review <> '' or d.rating > 0)
        order by d.updated_at desc limit 100`,
      [itemId],
    );
    return { reviews: rows };
  });

  // ── Каталог (қоғамдық): Кітап/Фильм/Подкаст. Мобайл app осыдан тартады. ──
  app.get('/library/catalog', async (req) => {
    const cat = (req.query as { category?: string }).category ?? null;
    // ПЕРФОРМАНС: каталог тек админ өзгерткенде жаңарады — 5 мин кэш (әр ашылғанда DB-ні соқпайды).
    const items = await getOrSet(`library:${cat ?? 'all'}`, 5 * 60_000, async () => {
      const { rows } = await query(
        `select ${LIB_COLS} from library_items
          where is_published = true and ($1::text is null or category = $1)
          order by category, sort_order, title`,
        [cat],
      );
      return rows;
    });
    return { items };
  });

  // ── Админ: барлық элементтер (жарияланбағанды қоса) ──
  app.get('/admin/library', { onRequest: [app.requireAdmin] }, async (req) => {
    const cat = (req.query as { category?: string }).category ?? null;
    const { rows } = await query(
      `select ${LIB_COLS}, created_at, updated_at from library_items
        where ($1::text is null or category = $1)
        order by category, sort_order, title`,
      [cat],
    );
    return { items: rows };
  });

  // ── Админ: пікір/рейтинг қорытындысы (маркетинг — қай кітап/фильм/подкаст танымал) ──
  // Әр элемент бойынша пікір саны + орташа пайдаланушы рейтингі + сақтағандар саны.
  app.get('/admin/library/reviews', { onRequest: [app.requireAdmin] }, async (req) => {
    const cat = (req.query as { category?: string }).category ?? null;
    const { rows } = await query(
      `select li.id, li.category, li.title, li.author, li.cover_url,
              count(*) filter (where d.review is not null and d.review <> '')::int as review_count,
              count(*) filter (where d.rating > 0)::int as rating_count,
              round(avg(d.rating) filter (where d.rating > 0), 2) as avg_user_rating,
              count(*) filter (where d.saved)::int as saved_count
         from library_items li
         left join library_user_data d on d.item_id = li.id
        where ($1::text is null or li.category = $1)
        group by li.id, li.category, li.title, li.author, li.cover_url
       having count(*) filter (where d.rating > 0 or (d.review is not null and d.review <> '') or d.saved) > 0
        order by review_count desc, rating_count desc, avg_user_rating desc nulls last
        limit 200`,
      [cat],
    );
    return { items: rows };
  });

  // ── Админ: бір элементтің барлық пікірлері (мәтінмен) ──
  app.get('/admin/library/:itemId/reviews', { onRequest: [app.requireAdmin] }, async (req) => {
    const itemId = (req.params as { itemId: string }).itemId;
    const { rows } = await query(
      `select u.name, u.phone, d.rating, d.review, d.updated_at
         from library_user_data d
         join users u on u.id = d.user_id
        where d.item_id = $1 and (d.rating > 0 or (d.review is not null and d.review <> ''))
        order by d.updated_at desc limit 200`,
      [itemId],
    );
    return { reviews: rows };
  });

  // ── Админ: жаңа элемент ──
  app.post('/admin/library', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const parsed = LibItemBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;
    const id = d.id || `${d.category[0]}-${Date.now()}`;
    const { rows } = await query(
      `insert into library_items
         (id, category, title, author, topic, year, rating, rating_max, rating_source, isbn,
          cover_url, youtube_id, external_url, lang, summary, ideas, conclusion, sort_order, is_published)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19)
       returning ${LIB_COLS}`,
      [
        id, d.category, d.title, d.author ?? '', d.topic ?? null, d.year ?? null, d.rating ?? null,
        d.rating_max ?? 5, d.rating_source ?? null, d.isbn ?? null, d.cover_url ?? null,
        d.youtube_id ?? null, d.external_url ?? null, d.lang ?? null,
        JSON.stringify(d.summary ?? {}), JSON.stringify(d.ideas ?? {}),
        d.conclusion ? JSON.stringify(d.conclusion) : null, d.sort_order ?? 0, d.is_published ?? true,
      ],
    );
    invalidatePrefix('library:'); // кэшті жаңартамыз — өзгеріс бірден көрінеді
    return { item: rows[0] };
  });

  // ── Админ: өзгерту (ішінара) ──
  app.patch('/admin/library/:id', { onRequest: [app.requireAdmin] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = LibItemBody.partial().safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const set: string[] = [];
    const args: unknown[] = [id];
    for (const [k, v] of Object.entries(parsed.data)) {
      if (v === undefined || k === 'id') continue;
      const json = LIB_JSONB.has(k);
      args.push(json ? JSON.stringify(v) : v);
      set.push(`${k} = $${args.length}${json ? '::jsonb' : ''}`);
    }
    if (set.length === 0) return { ok: true };
    set.push('updated_at = now()');
    const { rows } = await query(`update library_items set ${set.join(', ')} where id = $1 returning ${LIB_COLS}`, args);
    if (!rows[0]) return reply.code(404).send({ error: 'not_found' });
    invalidatePrefix('library:'); // кэшті жаңартамыз — өзгеріс бірден көрінеді
    return { item: rows[0] };
  });

  // ── Админ: жою ──
  app.delete('/admin/library/:id', { onRequest: [app.requireAdmin] }, async (req) => {
    await query('delete from library_items where id = $1', [(req.params as { id: string }).id]);
    invalidatePrefix('library:');
    return { ok: true };
  });
}
