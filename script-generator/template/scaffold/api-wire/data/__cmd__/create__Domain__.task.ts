import { BaseFailure, ResultV2 as Result, toBaseFailure } from '@inh-lib/common';
import { Create__Domain__TaskInput } from './internal.type';
import { checkSkuFlow } from './flows';
import { insert__Domain__DAF } from './db.logic';
import { transform__Domain__ToOutput } from './data.logic';
import { Create__Domain__Output } from '@__WS__/__API__-core/__DOMAIN_API__/command/create-__DOMAIN__';

// Orchestration + Unit of Work ($transaction): throw ใน scope = rollback
export async function create__Domain__Task(
  input: Create__Domain__TaskInput,
): Promise<Result<Create__Domain__Output, BaseFailure>> {
  const { context, telemetryService, client, props } = input;
  const { telemetryLogger: logger } = telemetryService.getActiveTelemetry(context);

  try {
    const raw = await client.$transaction(async (tx) => {
      // ── Zone 1: validation (read) ──────────────────────
      const sku = await checkSkuFlow({ client: tx, context, props });
      if (sku.isLeft()) throw sku.value;

      // ── Zone 2: write (atomic) ─────────────────────────
      const created = await insert__Domain__DAF(tx, {
        name: props.name,
        sku: props.sku,
        price: props.price,
        description: props.description,
      });
      if (created.isLeft()) throw created.value;

      return transform__Domain__ToOutput(created.value);
    });
    return Result.ok(raw);
  } catch (error) {
    const baseFail = toBaseFailure(error);
    logger.error('create-__domain__ fail', baseFail);
    return Result.fail(baseFail);
  }
}
