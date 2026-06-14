import { NodeSDK } from '@opentelemetry/sdk-node';
import {
  ConsoleUnifiedTelemetryProvider,
  UnifiedTelemetryProvider,
} from '@inh-lib/unified-telemetry-core';
import { OtelProviderService } from '@inh-lib/unified-telemetry-otel';

// ---------------------------------------------------------------------------
// env-driven telemetry provider
//  - ตั้ง OTEL_EXPORTER_OTLP_ENDPOINT -> ส่ง trace จริงผ่าน OTEL
//    (NodeSDK อ่าน OTEL_* env อัตโนมัติ เช่น endpoint / protocol / headers)
//  - ไม่ตั้ง -> Console provider (dev: ไม่ต้องมี collector)
// config ทั้งหมดอยู่ใน .env (ดู .env.example)
// ---------------------------------------------------------------------------
export function createTelemetryProvider(): UnifiedTelemetryProvider {
  const serviceName =
    process.env.OTEL_SERVICE_NAME || process.env.SERVICE_NAME || 'webapi';
  const serviceVersion = process.env.SERVICE_VERSION || '1.0.0';
  const environment =
    (process.env.NODE_ENV as 'development' | 'staging' | 'production') || 'development';

  if (!process.env.OTEL_EXPORTER_OTLP_ENDPOINT) {
    return new ConsoleUnifiedTelemetryProvider({ serviceName, serviceVersion, environment });
  }

  const sdk = new NodeSDK({});
  sdk.start();
  return OtelProviderService.createProviderWithConsole(
    { config: { serviceName, serviceVersion, environment } },
    sdk,
  );
}
