#!/usr/bin/env node
// Library каталогын (Кітап/Фильм/Подкаст) + Курстарды DB-ге салады.
// Дереккөз: src/db/seed_data/{library_items,courses}.json (mobile fixture-ден экспортталған,
// генератор: mobile/tool/export_catalog.dart).
//
// Қолданыс:
//   node scripts/seed-catalog.js          # бар жазбаларды САҚТАЙДЫ (on conflict do nothing)
//   node scripts/seed-catalog.js --force  # бар жазбаларды ҚАЙТА ЖАЗАДЫ (admin өзгерістерін басады)
import 'dotenv/config';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const { Pool } = pg;
const here = dirname(fileURLToPath(import.meta.url));
const dataDir = join(here, '..', 'src', 'db', 'seed_data');
const force = process.argv.includes('--force');

if (!process.env.DATABASE_URL) {
  console.error('DATABASE_URL not set. Copy .env.example → .env and configure.');
  process.exit(1);
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : undefined,
});

const readJson = (f) => JSON.parse(readFileSync(join(dataDir, f), 'utf8'));

async function seedLibrary() {
  const items = readJson('library_items.json');
  const conflict = force
    ? `do update set category = excluded.category, title = excluded.title, author = excluded.author,
         topic = excluded.topic, year = excluded.year, rating = excluded.rating, rating_max = excluded.rating_max,
         rating_source = excluded.rating_source, isbn = excluded.isbn, cover_url = excluded.cover_url,
         youtube_id = excluded.youtube_id, external_url = excluded.external_url, lang = excluded.lang,
         summary = excluded.summary, ideas = excluded.ideas, conclusion = excluded.conclusion,
         sort_order = excluded.sort_order, updated_at = now()`
    : 'do nothing';

  let n = 0;
  for (const it of items) {
    await pool.query(
      `insert into library_items
         (id, category, title, author, topic, year, rating, rating_max, rating_source, isbn,
          cover_url, youtube_id, external_url, lang, summary, ideas, conclusion, sort_order)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
       on conflict (id) ${conflict}`,
      [
        it.id, it.category, it.title, it.author ?? '', it.topic ?? null, it.year ?? null,
        it.rating ?? null, it.rating_max ?? 5, it.rating_source ?? null, it.isbn ?? null,
        it.cover_url ?? null, it.youtube_id ?? null, it.external_url ?? null, it.lang ?? null,
        JSON.stringify(it.summary ?? {}), JSON.stringify(it.ideas ?? {}),
        it.conclusion && Object.keys(it.conclusion).length ? JSON.stringify(it.conclusion) : null,
        it.sort_order ?? 0,
      ],
    );
    n++;
  }
  const { rows } = await pool.query(
    `select category, count(*)::int from library_items group by category order by category`,
  );
  console.log(`  library_items: ${n} processed →`, Object.fromEntries(rows.map((r) => [r.category, r.count])));
}

async function seedCourses() {
  const courses = readJson('courses.json');
  const conflict = force
    ? `do update set title = excluded.title, subtitle = excluded.subtitle, description = excluded.description,
         price_bonus = excluded.price_bonus, emoji = excluded.emoji, accent = excluded.accent,
         sort_order = excluded.sort_order, content = excluded.content, updated_at = now()`
    : 'do nothing';

  let n = 0;
  for (const c of courses) {
    await pool.query(
      `insert into course_catalog
         (id, title, subtitle, description, price_bonus, emoji, accent, sort_order, content)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9)
       on conflict (id) ${conflict}`,
      [
        c.id, JSON.stringify(c.title ?? {}), JSON.stringify(c.subtitle ?? {}),
        JSON.stringify(c.description ?? {}), c.price_bonus ?? 0, c.emoji ?? '🧠',
        c.accent ?? 4280640491, c.sort_order ?? 0, JSON.stringify(c.content ?? {}),
      ],
    );
    n++;
  }
  console.log(`  course_catalog: ${n} processed`);
}

async function seedAcademyLessons() {
  const items = readJson('academy_lessons.json');
  const conflict = force
    ? `do update set profile_type = excluded.profile_type, source_type = excluded.source_type,
         source_name = excluded.source_name, tag = excluded.tag, xp = excluded.xp,
         external_url = excluded.external_url, title = excluded.title, quote = excluded.quote,
         explanation = excluded.explanation, gold_application = excluded.gold_application,
         quick_check = excluded.quick_check, sort_order = excluded.sort_order, updated_at = now()`
    : 'do nothing';
  let n = 0;
  for (const l of items) {
    await pool.query(
      `insert into academy_lessons
         (id, profile_type, source_type, source_name, tag, xp, external_url,
          title, quote, explanation, gold_application, quick_check, sort_order)
       values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
       on conflict (id) ${conflict}`,
      [
        l.id, l.profile_type, l.source_type, l.source_name ?? '', l.tag ?? null, l.xp ?? 25,
        l.external_url ?? null, JSON.stringify(l.title ?? {}), JSON.stringify(l.quote ?? {}),
        JSON.stringify(l.explanation ?? {}), JSON.stringify(l.gold_application ?? {}),
        JSON.stringify(l.quick_check ?? {}), l.sort_order ?? 0,
      ],
    );
    n++;
  }
  console.log(`  academy_lessons: ${n} processed`);
}

async function seedGallup() {
  const items = readJson('gallup_questions.json');
  const conflict = force
    ? `do update set text = excluded.text, options = excluded.options, sort_order = excluded.sort_order`
    : 'do nothing';
  let n = 0;
  for (const q of items) {
    await pool.query(
      `insert into gallup_questions (id, text, options, sort_order)
       values ($1,$2,$3,$4) on conflict (id) ${conflict}`,
      [q.id, JSON.stringify(q.text ?? {}), JSON.stringify(q.options ?? []), q.sort_order ?? 0],
    );
    n++;
  }
  console.log(`  gallup_questions: ${n} processed`);
}

console.log(`Seeding catalog (${force ? 'FORCE overwrite' : 'preserve existing'})…`);
await seedLibrary();
await seedCourses();
await seedAcademyLessons();
await seedGallup();
await pool.end();
console.log('✓ catalog seed complete');
