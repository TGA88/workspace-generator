import { FastifyPluginAsync } from 'fastify';
import { createUnifiedFastifyHandler } from '@inh-lib/api-util-fastify';
import { addRegistryItem, getRegistryItem, UnifiedHttpContext } from '@inh-lib/unified-route';
import { TelemetryMiddlewareService } from '@inh-lib/unified-telemetry-middleware';
import { TELEMETRY_CONTEXT_KEYS } from '@inh-lib/unified-telemetry-core';
import { PrismaClient, getPrismaInstance } from '@__WS__/__DATA__-store-prisma';
import { Repository } from '@__WS__/__API__-core/__DOMAIN_API__/query/get-__DOMAIN__';
import { Get__Domain__Entry } from '@__WS__/__DATA__-store-prisma/__DOMAIN_API__/query/get-__DOMAIN__';
import { __DOMAINUP___API_CONTEXT_KEY } from '@__WS__/__API__-core/__DOMAIN_API__';
import { get__Domain__Endpoint } from '@__WS__/__API__-service/__DOMAIN_API__/query/get-__DOMAIN__';

const get__Domain__Route: FastifyPluginAsync = async (fastify): Promise<void> => {
  fastify.get('/:id', {
    preHandler: (req, _reply, done) => {
      const ctx = req.unifiedAppContext as UnifiedHttpContext;
      const prismaClient: PrismaClient = getPrismaInstance();

      const telemetryService = getRegistryItem<TelemetryMiddlewareService>(
        ctx,
        TELEMETRY_CONTEXT_KEYS.MIDDLEWARE_SERVICE,
      );
      if (telemetryService instanceof Error) {
        throw new Error('Telemetry service not found in context');
      }

      const repository: Repository = new Get__Domain__Entry(prismaClient, telemetryService);
      addRegistryItem(ctx, __DOMAINUP___API_CONTEXT_KEY.REPO_GET___DOMAINUP__, repository);
      done();
    },
    handler: createUnifiedFastifyHandler(get__Domain__Endpoint),
  });
};

export default get__Domain__Route;
