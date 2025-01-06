/* eslint-disable @typescript-eslint/no-namespace */
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
}
