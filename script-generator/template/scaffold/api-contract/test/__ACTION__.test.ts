// backend-test/__SERVICE__/__DOMAIN_API__/__ACTION__.test.ts — 1 action = 1 file (node:test)
// data-driven: วน c*/e* จาก _cases.json · setup/teardown ราย action (before/after) + case (ใน it)
// migrate/init/seed(shared/tenant/domain) → โหลดที่ bring-up ผ่าน make+liquibase (นอกไฟล์นี้)
import { describe, it, before, after } from 'node:test';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { httpRequest, runSqlFile, assertContract, loadCases } from '../../lib/index.ts';

const CONTRACT_DIR = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '../../../infrastructure/contract/__SERVICE__/__DOMAIN_API__/__ACTION__',
);

describe('__ACTION__', () => {
  before(async () => {
    await runSqlFile(path.join(CONTRACT_DIR, 'setup.sql')); // ① action — once/ไฟล์
  });
  after(async () => {
    await runSqlFile(path.join(CONTRACT_DIR, 'teardown.sql')); // ⑤ action — once
  });

  for (const c of loadCases(CONTRACT_DIR)) {
    it(`${c.key} — ${c.desc}`, async () => {
      if (c.setup) await runSqlFile(path.join(CONTRACT_DIR, c.setup)); // ② case-level (เช่น setup.e1.sql)
      const res = await httpRequest(c.withRequest); // ③ ยิงเข้า API จริง
      assertContract(res, c.withResponse); // ④ assert เทียบ contract
      if (c.teardown) await runSqlFile(path.join(CONTRACT_DIR, c.teardown));
    });
  }
});
