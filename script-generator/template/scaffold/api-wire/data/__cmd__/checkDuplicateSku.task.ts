import { BaseFailure, ResultV2 as Result, toBaseFailure } from '@inh-lib/common';
import { Create__Domain__TaskInput } from './internal.type';
import { findBySkuDAF } from './db.logic';
import { CheckDuplicateSkuOutput } from '@__WS__/__API__-core/__DOMAIN_API__/command/create-__DOMAIN__';

// Query ตรง ๆ: task เรียก DAF โดยตรง (ไม่มี flow / transaction)
export async function checkDuplicateSkuTask(
  input: Create__Domain__TaskInput,
): Promise<Result<CheckDuplicateSkuOutput, BaseFailure>> {
  const { client, props } = input;
  const existing = await findBySkuDAF(client, { sku: props.sku });
  if (existing.isLeft()) return Result.fail(toBaseFailure(existing.value));
  return Result.ok({ isDuplicate: Boolean(existing.value) });
}
