import { Result } from '@inh-lib/common';
import { CancelBibleInput, CancelBibleOutput } from './type.cancel-bible';
import { GetBibleDetailInput, GetBibleDetailOutput } from './type.get-bible-detail';

export interface Repository {
  getBibleDetail(input: GetBibleDetailInput): Promise<Result<GetBibleDetailOutput>>;
  cancelBible(input: CancelBibleInput): Promise<Result<CancelBibleOutput>>;
}
