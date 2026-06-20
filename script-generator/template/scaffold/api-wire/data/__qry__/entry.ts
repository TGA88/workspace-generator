import { UnifiedHttpContext } from '@inh-lib/unified-route';
import { BaseFailure, ResultV2 as Result } from '@inh-lib/common';
import { TelemetryMiddlewareService } from '@inh-lib/unified-telemetry-middleware';
import { PrismaClient } from '../../../dbclient';
import {
  Get__Domain__Input,
  Get__Domain__Output,
  Repository,
} from '@__WS__/__API__-core/__DOMAIN_API__/query/get-__DOMAIN__';
import { get__Domain__Task } from './get__Domain__.task';

// Data Access Provider — implement core Repository, delegate ไปยัง task
export class Get__Domain__Entry implements Repository {
  constructor(
    private readonly client: PrismaClient,
    private readonly telemetryService: TelemetryMiddlewareService,
  ) {}

  async get__Domain__(
    context: UnifiedHttpContext,
    props: Get__Domain__Input,
  ): Promise<Result<Get__Domain__Output, BaseFailure>> {
    return get__Domain__Task({
      context,
      telemetryService: this.telemetryService,
      client: this.client,
      props,
    });
  }
}
