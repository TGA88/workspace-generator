import { BaseFailure, Either, left, right } from '@inh-lib/common';
import { CheckSkuFlowInput, DuplicateSkuFailure } from './internal.type';
import { findBySkuDAF } from './db.logic';

// ─── checkSkuFlow ────────────────────────────────────────────
// guard ก่อน insert: ถ้า sku ซ้ำ → left(DuplicateSkuFailure) เพื่อให้ task throw rollback
export async function checkSkuFlow(input: CheckSkuFlowInput): Promise<Either<BaseFailure, true>> {
  const { client, props } = input;

  const existing = await findBySkuDAF(client, { sku: props.sku });
  if (existing.isLeft()) return left(existing.value);

  if (existing.value) return left(new DuplicateSkuFailure(`SKU ${props.sku} already exists`));
  return right(true);
}
