import { ResultV2 as Result, BaseFailure } from '@inh-lib/common';
import { UnifiedHttpContext } from '@inh-lib/unified-route';
import { Get__Domain__Input, Get__Domain__Output } from './type';

export interface Repository {
  get__Domain__(
    context: UnifiedHttpContext,
    props: Get__Domain__Input,
  ): Promise<Result<Get__Domain__Output, BaseFailure>>;
}
