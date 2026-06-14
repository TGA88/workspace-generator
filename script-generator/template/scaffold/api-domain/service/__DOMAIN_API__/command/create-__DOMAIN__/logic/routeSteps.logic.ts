import { CommonFailures, ResultV2 as Result } from '@inh-lib/common';
import { getRegistryItem, UnifiedHandlerFn, UnifiedPreHandlerFn } from '@inh-lib/unified-route';
import { TELEMETRY_CONTEXT_KEYS } from '@inh-lib/unified-telemetry-core';
import { TelemetryMiddlewareService } from '@inh-lib/unified-telemetry-middleware';
import { ZodType } from 'zod';

import { InputDTO, OutputDTO, inputDTO } from '../dto';
import {
  Repository,
  Create__Domain__Input,
} from '@__WS__/__API__-core/__DOMAIN_API__/command/create-__DOMAIN__';
import { __DOMAINUP___API_CONTEXT_KEY } from '@__WS__/__API__-core/__DOMAIN_API__';
import { createMapReqToInputPreHandler } from '../../../../shared/pre-handler/create-map-req-to-input.pre-handler';
import { authGuardPreHandler } from '../../../../shared/pre-handler/auth-guard.pre-handler';
import { validateCreate__Domain__Input } from './business.logic';

// helper: ดึง telemetry (logger + traceId) จาก registry
const getTelemetry = (
  context: Parameters<UnifiedHandlerFn>[0],
): ReturnType<TelemetryMiddlewareService['getActiveTelemetry']> => {
  const telemetryService = getRegistryItem<TelemetryMiddlewareService>(
    context,
    TELEMETRY_CONTEXT_KEYS.MIDDLEWARE_SERVICE,
  ) as TelemetryMiddlewareService;
  return telemetryService.getActiveTelemetry(context);
};

// step 1: map request body -> InputDTO -> validate schema -> registry
export const mapReqToInputPreHandler = createMapReqToInputPreHandler(
  inputDTO as unknown as ZodType,
  (context) => ({
    name: context.request.body['name'],
    sku: context.request.body['sku'],
    price: context.request.body['price'],
    description: context.request.body['description'],
  }),
);

// step 2: business validation (required fields / rules)
export const processCheckRequiredFieldPreHandler: UnifiedHandlerFn = async (context) => {
  const { telemetryLogger: logger, traceId } = getTelemetry(context);
  const inputRequest = getRegistryItem<InputDTO>(context, 'inputRequest') as InputDTO;

  const validationResult = validateCreate__Domain__Input(inputRequest as Create__Domain__Input);
  if (!validationResult.isValid) {
    logger.error('validate-create-__DOMAIN__-input fail', new Error(validationResult.message));
    return Result.fail(new CommonFailures.ParseFail(validationResult.message))
      .withTraceId(traceId as string)
      .toHttpResponse(context.response);
  }
};

// step 3: check duplicate sku ใน repo (inject ผ่าน DI)
export const processCheckDuplicateInRepoPreHandler: UnifiedHandlerFn = async (context) => {
  const { telemetryLogger: logger, traceId } = getTelemetry(context);
  const inputRequest = getRegistryItem<InputDTO>(context, 'inputRequest') as InputDTO;
  const repo = getRegistryItem<Repository>(
    context,
    __DOMAINUP___API_CONTEXT_KEY.REPO_CREATE___DOMAINUP__,
  ) as Repository;

  const result = await repo.checkDuplicateSku(context, { sku: inputRequest.sku });
  if (result.isFailure) {
    logger.error('check-duplicate-sku fail', new Error(String(result.errorValue())));
    return result.withTraceId(traceId as string).toHttpResponse(context.response);
  }
  if (result.getValue().isDuplicate) {
    logger.info('duplicate sku detected', { sku: inputRequest.sku });
    return Result.fail(new CommonFailures.ConflictFail(`Duplicate sku: ${inputRequest.sku}`))
      .withTraceId(traceId as string)
      .toHttpResponse(context.response);
  }
};

// final handler: create __domain__ ใน repo
export const processCreate__Domain__InRepoHandler: UnifiedHandlerFn = async (context) => {
  const { telemetryLogger: logger, traceId } = getTelemetry(context);
  const inputRequest = getRegistryItem<InputDTO>(context, 'inputRequest') as InputDTO;
  const repo = getRegistryItem<Repository>(
    context,
    __DOMAINUP___API_CONTEXT_KEY.REPO_CREATE___DOMAINUP__,
  ) as Repository;

  const result = await repo.create__Domain__(context, inputRequest as Create__Domain__Input);
  if (result.isFailure) {
    logger.error('create-__DOMAIN__ fail', new Error(String(result.errorValue())));
    return result.withTraceId(traceId as string).toHttpResponse(context.response);
  }
  const output: OutputDTO = { id: result.getValue().id, sku: result.getValue().sku };
  return Result.ok(output).withTraceId(traceId as string).toHttpResponse(context.response);
};

// setupProcess = wiring (ลำดับ pre-handlers + handler). pre-handler บริษัทเสียบเพิ่มผ่าน private overlay
export function setupProcess(): { preHandlers: UnifiedPreHandlerFn[]; handler: UnifiedHandlerFn } {
  return {
    preHandlers: [
      authGuardPreHandler, // <-- slot: ของจริงใช้ jwtAuth + permission
      mapReqToInputPreHandler,
      processCheckRequiredFieldPreHandler,
      processCheckDuplicateInRepoPreHandler,
    ],
    handler: processCreate__Domain__InRepoHandler,
  };
}
