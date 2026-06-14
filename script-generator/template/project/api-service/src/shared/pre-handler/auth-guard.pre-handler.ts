import {
  addRegistryItem,
  getRegistryItem,
  UnifiedPreHandlerFn,
} from '@inh-lib/unified-route';
import { TELEMETRY_CONTEXT_KEYS } from '@inh-lib/unified-telemetry-core';
import { TelemetryMiddlewareService } from '@inh-lib/unified-telemetry-middleware';
import { CommonFailures, ResultV2 as Result } from '@inh-lib/common';

export const CURRENT_USER_KEY = 'currentUser';
export type CurrentUser = { userId: string; roles: string[] };

// ===========================================================================
// GENERIC auth-guard stub — โชว์ "ช่อง (slot)" ของ pre-handler เฉยๆ
// ของจริงในบริษัท (jwt-auth / module-permission / check-endpoint) ให้ทำเป็น
// private overlay แล้วเสียบแทนตัวนี้ใน business.logic -> setupProcess().preHandlers
// (ดู docs/api-pattern.md)
// ===========================================================================
export const authGuardPreHandler: UnifiedPreHandlerFn = async (context) => {
  const telemetryService = getRegistryItem<TelemetryMiddlewareService>(
    context,
    TELEMETRY_CONTEXT_KEYS.MIDDLEWARE_SERVICE,
  ) as TelemetryMiddlewareService;
  const { telemetryLogger: logger, traceId } = telemetryService.getActiveTelemetry(context);

  const authorization = context.request.headers['authorization'];
  if (!authorization) {
    logger.error('auth-guard: missing authorization header');
    return Result.fail(new CommonFailures.UnauthorizedFail('Missing authorization header'))
      .withTraceId(traceId as string)
      .toHttpResponse(context.response);
  }

  // demo only: token format = "Bearer <userId>"
  const userId = authorization.replace(/^Bearer\s+/i, '').trim() || 'anonymous';
  addRegistryItem<CurrentUser>(context, CURRENT_USER_KEY, { userId, roles: ['user'] });
};
