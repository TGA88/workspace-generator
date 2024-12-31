/* eslint-disable @typescript-eslint/no-namespace */
import { Result, UseCaseError } from '@inh-lib/common';

export namespace Failures {
  export class ParseFail extends  Result<void,UseCaseError>  {
    constructor() {
      super(false, { message: 'Parse fail' } as UseCaseError);
    }
  }

  export class UpdateFail extends  Result<void,UseCaseError>  {
    constructor(message?: string) {
      super(false, { message: `Update fail: ${message}` } as UseCaseError);
    }
  }

  export class BibleDetailNotFound extends  Result<void,UseCaseError>  {
    constructor() {
      super(false, { message: 'Bible detail not found' } as UseCaseError);
    }
  }
  export class CheckConditionFail extends  Result<void,UseCaseError>  {
    constructor(message?: string) {
      super(false, { message: `${message}` } as UseCaseError);
    }
  }
}
