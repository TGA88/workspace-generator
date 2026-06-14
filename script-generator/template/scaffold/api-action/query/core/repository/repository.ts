import { ResultV2 as Result, BaseFailure } from '@inh-lib/common';
import { UnifiedHttpContext } from '@inh-lib/unified-route';
import { __Verb____Domain__Input, __Verb____Domain__Output } from './type';

export interface Repository {
  __verb____Domain__(
    context: UnifiedHttpContext,
    props: __Verb____Domain__Input,
  ): Promise<Result<__Verb____Domain__Output, BaseFailure>>;
}
