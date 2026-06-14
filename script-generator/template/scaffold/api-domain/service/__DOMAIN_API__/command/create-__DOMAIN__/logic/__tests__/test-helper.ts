import { UnifiedHttpContext } from '@inh-lib/unified-route';
import { TELEMETRY_CONTEXT_KEYS } from '@inh-lib/unified-telemetry-core';

export type CapturedResponse = { statusCode: number; body: unknown };

type TestLogger = {
  debug: (m?: string, a?: unknown) => void;
  info: (m?: string, a?: unknown) => void;
  warn: (m?: string, a?: unknown) => void;
  error: (m?: string, a?: unknown) => void;
  addSpanEvent: () => void;
  setSpanAttribute: () => void;
  finishSpan: () => void;
  createChildLogger: () => TestLogger;
};

export const noopLogger: TestLogger = {
  debug: (): void => undefined,
  info: (): void => undefined,
  warn: (): void => undefined,
  error: (): void => undefined,
  addSpanEvent: (): void => undefined,
  setSpanAttribute: (): void => undefined,
  finishSpan: (): void => undefined,
  createChildLogger: (): TestLogger => noopLogger,
};

export const fakeTelemetryService = {
  getActiveTelemetry: (): { telemetryLogger: TestLogger; telemetrySpan: object; traceId: string } => ({
    telemetryLogger: noopLogger,
    telemetrySpan: {},
    traceId: 'trace-test',
  }),
};

export function buildContext(
  registry: Record<string, unknown> = {},
  requestOverrides: Partial<UnifiedHttpContext['request']> = {},
): { ctx: UnifiedHttpContext; captured: CapturedResponse } {
  const captured: CapturedResponse = { statusCode: 200, body: undefined };
  const response = {
    sent: false,
    statusCode: 200,
    status(code: number) {
      captured.statusCode = code;
      return response;
    },
    json(data: unknown) {
      captured.body = data;
    },
    send(data: unknown) {
      captured.body = data;
      return data;
    },
    header() {
      return response;
    },
    redirect() {
      return undefined;
    },
  } as unknown as UnifiedHttpContext['response'];

  const ctx: UnifiedHttpContext = {
    request: {
      body: {},
      params: {},
      query: {},
      headers: {},
      method: 'POST',
      url: '/',
      route: '/',
      ip: '127.0.0.1',
      ...requestOverrides,
    },
    response,
    registry: {
      [TELEMETRY_CONTEXT_KEYS.MIDDLEWARE_SERVICE]: fakeTelemetryService,
      ...registry,
    },
  };
  return { ctx, captured };
}
