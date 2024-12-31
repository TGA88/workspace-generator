/* eslint-disable @typescript-eslint/no-namespace */
import { Result, UseCaseError } from '@inh-lib/common';

export namespace Failures {
  export class ParseFail extends  Result<void,UseCaseError>  {
    constructor() {
      super(false, { message: 'Parse fail' } as UseCaseError);
    }
  }
  export class StatusAlreadyDelete extends  Result<void,UseCaseError>  {
    constructor() {
      super(false, { message: 'Status already delete' } as UseCaseError);
    }
  }

  export class DeleteFail extends  Result<void,UseCaseError>  {
    constructor(message?: string) {
      super(false, { message: `Delete fail: ${message}` } as UseCaseError);
    }
  }

  export class GetFail extends  Result<void,UseCaseError>  {
    constructor(message?: string) {
      super(false, { message: `Get fail: ${message}` } as UseCaseError);
    }
  }
}
