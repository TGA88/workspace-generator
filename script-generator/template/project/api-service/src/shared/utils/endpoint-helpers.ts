import {
  getRegistryItem,
  UnifiedHandlerFn,
  UnifiedPreHandlerFn,
  UnifiedRouteHandler,
} from '@inh-lib/unified-route';
import { TELEMETRY_CONTEXT_KEYS } from '@inh-lib/unified-telemetry-core';
import {
  makeEndpointHandler,
  MakeEndpointHandlerInput,
  TelemetryMiddlewareService,
} from '@inh-lib/unified-telemetry-middleware';
import { createTelemetryApiPipeline } from '../pipeline/telemetry-api.pipeline';

export type SetupProcessFn = () => {
  preHandlers: UnifiedPreHandlerFn[];
  handler: UnifiedHandlerFn;
};

// แปลง setupProcess (preHandlers + handler) ให้เป็น route handler ที่ห่อด้วย telemetry pipeline
export const makeTelemetryEndpoint = (setupProcess: SetupProcessFn): UnifiedRouteHandler => {
  return async (context): Promise<void> => {
    const telemetryApiPipeline = createTelemetryApiPipeline();
    const telemetryService = getRegistryItem<TelemetryMiddlewareService>(
      context,
      TELEMETRY_CONTEXT_KEYS.MIDDLEWARE_SERVICE,
    ) as TelemetryMiddlewareService;

    const { preHandlers, handler } = setupProcess();

    const input: MakeEndpointHandlerInput = {
      propContext: { telemetryService },
      input: { preHandlers, handler, pipeline: telemetryApiPipeline },
    };

    const endpointHandler = makeEndpointHandler(input);
    await endpointHandler(context);
  };
};
