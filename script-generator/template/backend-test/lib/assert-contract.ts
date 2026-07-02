// assertContract — เทียบ response จริงกับ contract.withResponse
// skeleton: เช็ค status + envelope fields หลัก (isSuccess/codeResult) · ทีมเติม assertion ราย field ต่อ
import assert from 'node:assert/strict';
import type { HttpResult } from './http.ts';

export type WithResponse = {
  status: number;
  headers?: Record<string, string>;
  body?: Record<string, unknown>;
};

export function assertContract(res: HttpResult, expected: WithResponse): void {
  assert.equal(
    res.status,
    expected.status,
    `status: expected ${expected.status} got ${res.status}`,
  );

  const exp = expected.body;
  if (!exp) return;
  const body = (res.body ?? {}) as Record<string, unknown>;

  if ('isSuccess' in exp) assert.equal(body.isSuccess, exp.isSuccess, 'body.isSuccess');
  if ('codeResult' in exp) assert.equal(body.codeResult, exp.codeResult, 'body.codeResult');

  // TODO: assert ราย field ของ dataResult ตาม core Output type
  //   ค่าที่ dynamic (เช่น id ที่ DB gen) → match แบบ shape/regex ไม่ใช่ค่าตรงตัว
}
