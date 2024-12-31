/* eslint-disable @typescript-eslint/no-namespace */
import { Result, UseCaseError } from '@inh-lib/common';

export namespace Failures {
  export class ParseFail extends  Result<void,UseCaseError>  {
    constructor() {
      super(false, { message: 'Parse fail' } as UseCaseError);
    }
  }
  export class CreateFail extends  Result<void,UseCaseError>  {
    constructor(message?: string) {
      super(false, { message: `Create fail: ${message}` } as UseCaseError);
    }
  }
  export class GetFail extends  Result<void,UseCaseError>  {
    constructor() {
      super(false, { message: 'Get fail' } as UseCaseError);
    }
  }
  export class CheckConditionFail extends  Result<void,UseCaseError>  {
    constructor(message?: string) {
      super(false, { message: `${message}` } as UseCaseError);
    }
  }
}
