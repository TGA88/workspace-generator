import { ResultV2 as Result, BaseFailure } from '@inh-lib/common';
import { UnifiedHttpContext } from '@inh-lib/unified-route';
import {
  __Verb____Domain__Input,
  __Verb____Domain__Output,
  CheckDuplicateSkuInput,
  CheckDuplicateSkuOutput,
} from './type';

// Repository = DI contract (interface only). ตัว implementation จริงอยู่ใน data layer (store-prisma)
// แล้วถูก inject เข้า context ตอน composition root
export interface Repository {
  checkDuplicateSku(
    context: UnifiedHttpContext,
    props: CheckDuplicateSkuInput,
  ): Promise<Result<CheckDuplicateSkuOutput, BaseFailure>>;
  __verb____Domain__(
    context: UnifiedHttpContext,
    props: __Verb____Domain__Input,
  ): Promise<Result<__Verb____Domain__Output, BaseFailure>>;
}
