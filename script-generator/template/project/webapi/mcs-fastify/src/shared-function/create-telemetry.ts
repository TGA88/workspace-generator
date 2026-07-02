import { NodeSDK } from '@opentelemetry/sdk-node';
import {
  NoOpUnifiedTelemetryProvider,
  UnifiedTelemetryProvider,
} from '@inh-lib/unified-telemetry-core';
import { OtelProviderService } from '@inh-lib/unified-telemetry-otel';

// ---------------------------------------------------------------------------
// env-driven telemetry provider
//  - ตั้ง OTEL_EXPORTER_OTLP_ENDPOINT -> ส่ง trace จริงผ่าน OTEL
//    (NodeSDK อ่าน OTEL_* env อัตโนมัติ เช่น endpoint / protocol / headers)
//  - ไม่ตั้ง -> NoOp provider (dev/test: ไม่ต้องมี collector)
// ⚠️ ConsoleUnifiedTelemetryProvider (unified-telemetry-core@0.3.4) มีบั๊ก: ConsoleSpan.getSpanMetadata()
//    throw "Method not implemented." ซึ่ง endpoint pipeline ของ telemetry-middleware เรียก -> ทุก endpoint 500.
//    NoOp implement getSpanMetadata ครบ -> ใช้เป็น dev-default (จะเอา trace จริงให้ตั้ง OTEL endpoint)
// config ทั้งหมดอยู่ใน .env (ดู .env.example)
// ---------------------------------------------------------------------------
export function createTelemetryProvider(): UnifiedTelemetryProvider {
  const serviceName =
    process.env.OTEL_SERVICE_NAME || process.env.SERVICE_NAME || 'webapi';
  const serviceVersion = process.env.SERVICE_VERSION || '1.0.0';
  const environment =
    (process.env.NODE_ENV as 'development' | 'staging' | 'production') || 'development';

  if (!process.env.OTEL_EXPORTER_OTLP_ENDPOINT) {
    return new NoOpUnifiedTelemetryProvider({ serviceName, serviceVersion, environment });
  }

  const sdk = new NodeSDK({});
  sdk.start();
  return OtelProviderService.createProviderWithConsole(
    { config: { serviceName, serviceVersion, environment } },
    sdk,
  );
}
