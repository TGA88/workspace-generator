import { BaseFailure, ResultV2 as Result, toBaseFailure } from '@inh-lib/common';
import { Get__Domain__TaskInput, __Domain__NotFoundFailure } from './internal.type';
import { findByIdDAF } from './db.logic';
import { transform__Domain__ToOutput } from './data.logic';
import { Get__Domain__Output } from '@__WS__/__API__-core/__DOMAIN_API__/query/get-__DOMAIN__';

// Query: task เรียก DAF + transform ตรง ๆ (ไม่มี transaction)
export async function get__Domain__Task(
  input: Get__Domain__TaskInput,
): Promise<Result<Get__Domain__Output, BaseFailure>> {
  const { context, telemetryService, client, props } = input;
  const { telemetryLogger: logger } = telemetryService.getActiveTelemetry(context);

  const found = await findByIdDAF(client, { id: props.id });
  if (found.isLeft()) {
    logger.error('get-__domain__ fail', toBaseFailure(found.value));
    return Result.fail(found.value);
  }
  if (!found.value) return Result.fail(new __Domain__NotFoundFailure());

  return Result.ok(transform__Domain__ToOutput(found.value));
}
