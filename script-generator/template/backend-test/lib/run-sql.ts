// runSqlFile — รัน .sql (setup/teardown ราย action/case) เข้ากับ DB จริง
// action/case-level เท่านั้น — migrate/init/seed(shared/tenant/domain) โหลดที่ bring-up ผ่าน liquibase
import { readFile } from 'node:fs/promises';
import pg from 'pg';

const DATABASE_URL =
  process.env.DATABASE_URL ??
  'postgresql://postgres:postgres@localhost:5433/__DB_NAME__';
const SCHEMA = process.env.DB_SCHEMA_NAME ?? '__DB_SCHEMA_NAME__';

function isEffectivelyEmpty(sql: string): boolean {
  return sql
    .split('\n')
    .every((l) => l.trim() === '' || l.trim().startsWith('--'));
}

export async function runSqlFile(file: string): Promise<void> {
  const sql = (await readFile(file, 'utf8')).trim();
  if (!sql || isEffectivelyEmpty(sql)) return; // skeleton/comment-only → no-op

  const client = new pg.Client({ connectionString: DATABASE_URL });
  await client.connect();
  try {
    await client.query(`SET search_path TO "${SCHEMA}"`);
    await client.query(sql);
  } finally {
    await client.end();
  }
}
