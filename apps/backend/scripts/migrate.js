#!/usr/bin/env node
import 'dotenv/config';
import { readFileSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const { Pool } = pg;
const here = dirname(fileURLToPath(import.meta.url));

if (!process.env.DATABASE_URL) {
  console.error('DATABASE_URL not set. Copy .env.example → .env and configure.');
  process.exit(1);
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : undefined,
});

const sqlDir = join(here, '..', 'src', 'db');
const files = ['schema.sql', 'seed.sql'].filter((f) => {
  try { readFileSync(join(sqlDir, f)); return true; } catch { return false; }
});

console.log('Applying:', files.join(', '));

for (const f of files) {
  const sql = readFileSync(join(sqlDir, f), 'utf8');
  console.log(`→ ${f} (${sql.length} bytes)`);
  await pool.query(sql);
}

await pool.end();
console.log('✓ migrate complete');

// Avoid unused warning on `readdirSync` import if we extend later
void readdirSync;
