// per-service config (test-side) — test file import แล้วส่งเป็น param ให้ lib (lib pure, ไม่แตะ process.env)
// อ่าน env + default ของ service นี้ · override ได้ตอน run (make api-test / CI / pnpm dev)
// หลาย service = คนละไฟล์ _config.ts (คนละ baseUrl/prefix/schema)
import type { Target, DbConfig } from '../lib/index.ts';

// TARGET.prefix = prefix ที่ harness prepend ให้ contract.path · default '' (ยิงตรงเข้า app แบบ local)
// ⚠️ @fastify/autoload mount route ตาม folder (/<domain>-api/<action>) — ไม่ apply prefix ของ app.ts
//    → local app อยู่ที่ /product-api/.. (ไม่มี service prefix) · ถ้ายิงผ่าน gateway ที่มี prefix ให้ตั้ง API_PREFIX
export const TARGET: Target = {
  baseUrl: process.env.API_BASE_URL ?? 'http://localhost:3010',
  prefix: process.env.API_PREFIX ?? '',
};

export const DB: DbConfig = {
  databaseUrl: process.env.DATABASE_URL ?? 'postgresql://postgres:postgres@localhost:5433/__DB_NAME__',
  schema: process.env.DB_SCHEMA_NAME ?? '__DB_SCHEMA_NAME__',
};
