import { getRegistryItem, UnifiedPreHandlerFn } from '@inh-lib/unified-route';
import { TELEMETRY_CONTEXT_KEYS } from '@inh-lib/unified-telemetry-core';
import { TelemetryMiddlewareService } from '@inh-lib/unified-telemetry-middleware';

// กันพลาด: ยืนยันว่ามี telemetry middleware service ใน registry ก่อนรัน steps
export const checkTelemetryPreHandler: UnifiedPreHandlerFn = async (context) => {
  const telemetryService = getRegistryItem<TelemetryMiddlewareService>(
    context,
    TELEMETRY_CONTEXT_KEYS.MIDDLEWARE_SERVICE,
  );
  if (telemetryService instanceof Error) {
    throw new Error('Telemetry middleware service not found in registry');
  }
};
