// runSqlFile / queryRows — เข้าถึง DB จริง (setup/teardown ราย action/case + assert DB)
// lib = pure: รับ db config เป็น parameter · ไม่แตะ process.env (test file เป็นคนกำหนด)
// migrate/init/seed(shared/tenant/domain) โหลดที่ bring-up ผ่าน liquibase (นอก lib นี้)
import { readFile } from 'node:fs/promises';
import pg from 'pg';

// DbConfig = ปลายทาง DB (ต่าง service/schema คนละค่า) · schema = search_path
export type DbConfig = { databaseUrl: string; schema: string };

function isEffectivelyEmpty(sql: string): boolean {
  return sql
    .split('\n')
    .every((l) => l.trim() === '' || l.trim().startsWith('--'));
}

export async function runSqlFile(file: string, db: DbConfig): Promise<void> {
  const sql = (await readFile(file, 'utf8')).trim();
  if (!sql || isEffectivelyEmpty(sql)) return; // skeleton/comment-only → no-op

  const client = new pg.Client({ connectionString: db.databaseUrl });
  await client.connect();
  try {
    await client.query(`SET search_path TO "${db.schema}"`);
    await client.query(sql);
  } finally {
    await client.end();
  }
}

// queryRows — SELECT ตรงเข้า DB จริง คืน rows (ใช้ assert side-effect เช่น row ที่ create ลง DB จริง)
// params เป็น $1,$2,... (parameterized)
export async function queryRows<T = Record<string, unknown>>(
  sql: string,
  db: DbConfig,
  params: unknown[] = [],
): Promise<T[]> {
  const client = new pg.Client({ connectionString: db.databaseUrl });
  await client.connect();
  try {
    await client.query(`SET search_path TO "${db.schema}"`);
    const res = await client.query(sql, params);
    return res.rows as T[];
  } finally {
    await client.end();
  }
}
