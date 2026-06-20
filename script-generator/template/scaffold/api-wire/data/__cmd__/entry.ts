import { UnifiedHttpContext } from '@inh-lib/unified-route';
import { BaseFailure, ResultV2 as Result } from '@inh-lib/common';
import { TelemetryMiddlewareService } from '@inh-lib/unified-telemetry-middleware';
import { PrismaClient } from '../../../dbclient';
import {
  Create__Domain__Input,
  Create__Domain__Output,
  CheckDuplicateSkuInput,
  CheckDuplicateSkuOutput,
  Repository,
} from '@__WS__/__API__-core/__DOMAIN_API__/command/create-__DOMAIN__';
import { create__Domain__Task } from './create__Domain__.task';
import { checkDuplicateSkuTask } from './checkDuplicateSku.task';

// Data Access Provider — implement core Repository, delegate ทุก method ไปยัง task
export class Create__Domain__Entry implements Repository {
  constructor(
    private readonly client: PrismaClient,
    private readonly telemetryService: TelemetryMiddlewareService,
  ) {}

  async checkDuplicateSku(
    context: UnifiedHttpContext,
    props: CheckDuplicateSkuInput,
  ): Promise<Result<CheckDuplicateSkuOutput, BaseFailure>> {
    return checkDuplicateSkuTask({
      context,
      telemetryService: this.telemetryService,
      client: this.client,
      props,
    });
  }

  async create__Domain__(
    context: UnifiedHttpContext,
    props: Create__Domain__Input,
  ): Promise<Result<Create__Domain__Output, BaseFailure>> {
    return create__Domain__Task({
      context,
      telemetryService: this.telemetryService,
      client: this.client,
      props,
    });
  }
}
