import { UnifiedHttpContext } from '@inh-lib/unified-route';
import { TelemetryMiddlewareService } from '@inh-lib/unified-telemetry-middleware';
import { PrismaClient } from '../../../dbclient';
import { BaseFailure } from '@inh-lib/common';
import { Get__Domain__Input } from '@__WS__/__API__-core/__DOMAIN_API__/query/get-__DOMAIN__';

// ─── task input ──────────────────────────────────────────────
export interface Get__Domain__TaskInput {
  context: UnifiedHttpContext;
  telemetryService: TelemetryMiddlewareService;
  client: PrismaClient;
  props: Get__Domain__Input;
}

// ─── db.logic ────────────────────────────────────────────────
export type Raw__Domain__ = {
  id: string;
  sku: string;
  name: string;
  price: number;
  description: string | null;
};

// ─── custom errors ───────────────────────────────────────────
export class Get__Domain__DAFFail extends BaseFailure {
  constructor(message?: string, details?: unknown) {
    super('GET___DOMAINUP___DAF_FAIL', message ?? 'GET___DOMAINUP___DAF_FAIL', 500, details);
  }
}

export class __Domain__NotFoundFailure extends BaseFailure {
  constructor(message?: string, details?: unknown) {
    super('__DOMAINUP___NOT_FOUND', message ?? '__DOMAINUP___NOT_FOUND', 404, details);
  }
}
