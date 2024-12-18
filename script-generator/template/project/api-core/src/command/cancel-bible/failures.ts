
import { Result, UseCaseError } from '@inh-lib/common';

export namespace Failures {
  export class ParseFail extends Result<UseCaseError> {
    constructor() {
      super(false, { message: 'Parse fail' } as UseCaseError);
    }
  }

  export class GetFail extends Result<UseCaseError> {
    constructor() {
      super(false, { message: 'Get fail' } as UseCaseError);
    }
  }

  export class UpdateFail extends Result<UseCaseError> {
    constructor(message?: string) {
      super(false, { message: `Update fail: ${message}` } as UseCaseError);
    }
  }

  export class CheckConditionFail extends Result<UseCaseError> {
    constructor(message?: string) {
      super(false, { message: `${message}` } as UseCaseError);
    }
  }
}
