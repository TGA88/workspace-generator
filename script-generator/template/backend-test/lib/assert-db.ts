// assertDbState — assert side-effect ที่ลง DB จริง (persistence) หลังยิง API
// สำคัญกับ action ที่ "เปลี่ยน state" (create/update/delete) — HTTP 200 ไม่ได้แปลว่า row ลง DB
// data-driven: อ่าน block `assertDb` จาก contract (c*/e*.json) → run SELECT + เทียบ
import assert from 'node:assert/strict';
import { queryRows } from './run-sql.ts';

export type AssertDb = {
  query: string; // SELECT (parameterized ด้วย $1.. ถ้าใส่ params)
  params?: unknown[];
  rowCount?: number; // จำนวน row ที่คาด (เช่น 1 = created, 0 = ไม่ถูกสร้าง)
  row?: Record<string, unknown>; // เทียบ column→value ของ row แรก (subset — เช็คเฉพาะ field ที่ระบุ)
};

export async function assertDbState(a: AssertDb): Promise<void> {
  const rows = await queryRows(a.query, a.params ?? []);

  if (a.rowCount !== undefined) {
    assert.equal(rows.length, a.rowCount, `db rowCount: expected ${a.rowCount} got ${rows.length}`);
  }

  if (a.row) {
    const actual = (rows[0] ?? {}) as Record<string, unknown>;
    for (const [k, v] of Object.entries(a.row)) {
      assert.deepEqual(
        actual[k],
        v,
        `db row.${k}: expected ${JSON.stringify(v)} got ${JSON.stringify(actual[k])}`,
      );
    }
  }
}
