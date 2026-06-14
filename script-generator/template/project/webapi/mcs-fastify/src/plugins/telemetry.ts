import fp from 'fastify-plugin';
import { TelemetryPluginService } from '@inh-lib/api-util-fastify';
import { createTelemetryProvider } from '../shared-function/create-telemetry';

// plugin นี้: สร้าง req.unifiedAppContext ต่อ request + ลง TelemetryMiddlewareService
// ลง registry (TELEMETRY_CONTEXT_KEYS.MIDDLEWARE_SERVICE) ให้ routeSteps ใช้
// provider เลือกเองตาม .env (OTEL จริง หรือ Console) -> ดู create-telemetry.ts
export default fp(async (fastify) => {
  const telemetryProvider = createTelemetryProvider();
  const telemetryPlugin = TelemetryPluginService.createPlugin({
    telemetryProvider,
    autoTracing: true,
    serviceName: process.env.OTEL_SERVICE_NAME || 'webapi',
  });
  await fastify.register(telemetryPlugin);
});
