import { UnifiedRoutePipeline } from '@inh-lib/unified-route';
import { checkTelemetryPreHandler } from '../pre-handler/check-telemetry.pre-handler';

// pipeline กลางของทุก endpoint: ใส่ telemetry guard ไว้หน้าสุด
export function createTelemetryApiPipeline(): UnifiedRoutePipeline {
  return new UnifiedRoutePipeline().addPreHandler(checkTelemetryPreHandler);
}
