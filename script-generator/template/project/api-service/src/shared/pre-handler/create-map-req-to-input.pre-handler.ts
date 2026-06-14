import { z } from 'zod';
import {
  addRegistryItem,
  getRegistryItem,
  UnifiedHttpContext,
  UnifiedPreHandlerFn,
} from '@inh-lib/unified-route';
import { TELEMETRY_CONTEXT_KEYS } from '@inh-lib/unified-telemetry-core';
import { TelemetryMiddlewareService } from '@inh-lib/unified-telemetry-middleware';
import { CommonFailures, ResultV2 as Result } from '@inh-lib/common';

// factory pre-handler: map request -> DTO -> validate ด้วย zod -> เก็บลง registry (key=inputRequest)
export const createMapReqToInputPreHandler =
  <S extends z.ZodType, T = z.infer<S>>(
    schema: S,
    mapRequest: (context: UnifiedHttpContext) => T,
    registryKey = 'inputRequest',
  ): UnifiedPreHandlerFn =>
  async (context) => {
    const telemetryService = getRegistryItem<TelemetryMiddlewareService>(
      context,
      TELEMETRY_CONTEXT_KEYS.MIDDLEWARE_SERVICE,
    ) as TelemetryMiddlewareService;
    const { telemetryLogger: logger, traceId } = telemetryService.getActiveTelemetry(context);

    const parsed = schema.safeParse(mapRequest(context));
    if (!parsed.success) {
      logger.error('Validate request fail', new Error(String(parsed.error)));
      return Result.fail(new CommonFailures.ParseFail(`Validate request fail: ${parsed.error}`))
        .withTraceId(traceId as string)
        .toHttpResponse(context.response);
    }
    addRegistryItem(context, registryKey, parsed.data);
  };
