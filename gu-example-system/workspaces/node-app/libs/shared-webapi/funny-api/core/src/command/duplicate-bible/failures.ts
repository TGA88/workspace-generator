/* eslint-disable @typescript-eslint/no-namespace */
import { Result, UseCaseError } from '@inh-lib/common';

export namespace Failures {
  export class ParseFail extends Result<UseCaseError> {
    constructor() {
      super(false, { message: 'Parse fail' } as UseCaseError);
    }
  }
  export class StatusNotEqualToExpiredOrCancel extends Result<UseCaseError> {
    constructor() {
      super(false, { message: 'Status not equal to submit or cancel' } as UseCaseError);
    }
  }

  export class DuplicateFail extends Result<UseCaseError> {
    constructor(message?: string) {
      super(false, { message: `Duplicate fail: ${message}` } as UseCaseError);
    }
  }

  export class CheckConditionFail extends Result<UseCaseError> {
    constructor(message?: string) {
      super(false, { message: `${message}` } as UseCaseError);
    }
  }
  export class GetFail extends Result<UseCaseError> {
    constructor(message?: string) {
      super(false, { message: `Get fail: ${message}` } as UseCaseError);
    }
  }

  export class StatusFail extends Result<UseCaseError> {
    constructor(message?: string) {
      super(false, { message: `Status fail: ${message}` } as UseCaseError);
    }
  }

}
