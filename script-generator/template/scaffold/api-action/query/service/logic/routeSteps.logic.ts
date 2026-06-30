import { ResultV2 as Result } from '@inh-lib/common';
import { getRegistryItem, UnifiedHandlerFn, UnifiedPreHandlerFn } from '@inh-lib/unified-route';
import { TELEMETRY_CONTEXT_KEYS } from '@inh-lib/unified-telemetry-core';
import { TelemetryMiddlewareService } from '@inh-lib/unified-telemetry-middleware';
import { ZodType } from 'zod';

import { InputDTO, OutputDTO, inputDTO } from '../dto';
import { Repository } from '@__WS__/__API__-core/__domain__-api/query/__verb__-__domain__';
import { __DOMAINUP___API_CONTEXT_KEY } from '@__WS__/__API__-core/__DOMAIN_API__';
import { createMapReqToInputPreHandler } from '../../../../shared/pre-handler/create-map-req-to-input.pre-handler';
import { authGuardPreHandler } from '../../../../shared/pre-handler/auth-guard.pre-handler';

const getTelemetry = (
  context: Parameters<UnifiedHandlerFn>[0],
): ReturnType<TelemetryMiddlewareService['getActiveTelemetry']> => {
  const telemetryService = getRegistryItem<TelemetryMiddlewareService>(
    context,
    TELEMETRY_CONTEXT_KEYS.MIDDLEWARE_SERVICE,
  ) as TelemetryMiddlewareService;
  return telemetryService.getActiveTelemetry(context);
};

export const mapReqToInputPreHandler = createMapReqToInputPreHandler(
  inputDTO as unknown as ZodType,
  (context) => ({ id: context.request.params['id'] ?? context.request.query['id'] }),
);

export const process__Verb____Domain__Handler: UnifiedHandlerFn = async (context) => {
  const { telemetryLogger: logger, traceId } = getTelemetry(context);
  const inputRequest = getRegistryItem<InputDTO>(context, 'inputRequest') as InputDTO;
  const repo = getRegistryItem<Repository>(
    context,
    __DOMAINUP___API_CONTEXT_KEY.__REPO_KEY__,
  ) as Repository;

  const result = await repo.__verb____Domain__(context, { id: inputRequest.id });
  if (result.isFailure) {
    logger.error('__verb__-__domain__ fail', new Error(String(result.errorValue())));
    return result.withTraceId(traceId as string).toHttpResponse(context.response);
  }
  const v = result.getValue();
  const output: OutputDTO = {
    id: v.id,
    name: v.name,
    sku: v.sku,
    price: v.price,
    description: v.description,
  };
  return Result.ok(output).withTraceId(traceId as string).toHttpResponse(context.response);
};

// __verb__-__domain__ ไม่มี pure logic แยก -> ไม่มี business.logic; setupProcess อยู่กับ steps
export function setupProcess(): { preHandlers: UnifiedPreHandlerFn[]; handler: UnifiedHandlerFn } {
  return {
    preHandlers: [authGuardPreHandler, mapReqToInputPreHandler],
    handler: process__Verb____Domain__Handler,
  };
}
