// contract-conformance (skeleton) — validate ว่า contract .json ตรงกับ core Input/Output types (กัน drift)
// เหตุผล: contract อยู่คนละ workspace กับ core contract.type.ts → ต้องมีเทสต์นี้จับ drift อัตโนมัติ
// วิธีเติม (ต่อ action):
//   1) import type จาก core + import envelope json (with { type: 'json' })
//   2) assign เพื่อ type-check ระดับ compile (drift → tsc/tsx error) + shape check ระดับ runtime
import { describe, it } from 'node:test';
import assert from 'node:assert/strict';

// ── ตัวอย่าง (ปลดคอมเมนต์ + ปรับ path/type ตาม action จริง) ─────────────────
// import type {
//   CreateProductInput,
//   CreateProductOutput,
// } from '@__WS__/__API__-core/product-api/command/create-product';
// import c1 from '../../infrastructure/contract/__SERVICE__/product-api/create-product/c1.json' with { type: 'json' };

describe('__SERVICE__ — contract conformance', () => {
  it('skeleton — เติม type-check ราย action (ดูตัวอย่างด้านบน)', () => {
    // const reqBody: CreateProductInput = c1.withRequest.body;                 // drift ที่ request → error
    // const resData: CreateProductOutput = c1.withResponse.body.dataResult;    // drift ที่ response → error
    // assert.ok(reqBody && resData);
    assert.ok(true);
  });
});
