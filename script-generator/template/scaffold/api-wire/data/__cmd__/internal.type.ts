import { UnifiedHttpContext } from '@inh-lib/unified-route';
import { TelemetryMiddlewareService } from '@inh-lib/unified-telemetry-middleware';
import { PrismaClient, Prisma } from '../../../dbclient';
import { BaseFailure } from '@inh-lib/common';
import { Create__Domain__Input } from '@__WS__/__API__-core/__DOMAIN_API__/command/create-__DOMAIN__';

// ─── task input ──────────────────────────────────────────────
export interface Create__Domain__TaskInput {
  context: UnifiedHttpContext;
  telemetryService: TelemetryMiddlewareService;
  client: PrismaClient;
  props: Create__Domain__Input;
}

// ─── flows ───────────────────────────────────────────────────
export interface CheckSkuFlowInput {
  client: PrismaClient | Prisma.TransactionClient;
  context: UnifiedHttpContext;
  props: Create__Domain__Input;
}

// ─── db.logic ────────────────────────────────────────────────
export interface Insert__Domain__DbInput {
  name: string;
  sku: string;
  price: number;
  description?: string;
  createBy?: string;
}

export type Raw__Domain__ = {
  id: string;
  sku: string;
  name: string;
  price: number;
  description: string | null;
  createdBy: string | null;
  createdAt: Date;
  updatedBy: string | null;
  updatedAt: Date;
};

// ─── custom errors ───────────────────────────────────────────
export class Create__Domain__DAFFail extends BaseFailure {
  constructor(message?: string, details?: unknown) {
    super('CREATE___DOMAINUP___DAF_FAIL', message ?? 'CREATE___DOMAINUP___DAF_FAIL', 500, details);
  }
}

export class CheckSkuDAFFail extends BaseFailure {
  constructor(message?: string, details?: unknown) {
    super('CHECK_SKU_DAF_FAIL', message ?? 'CHECK_SKU_DAF_FAIL', 500, details);
  }
}

export class DuplicateSkuFailure extends BaseFailure {
  constructor(message?: string, details?: unknown) {
    super('DUPLICATE_SKU', message ?? 'DUPLICATE_SKU', 409, details);
  }
}
