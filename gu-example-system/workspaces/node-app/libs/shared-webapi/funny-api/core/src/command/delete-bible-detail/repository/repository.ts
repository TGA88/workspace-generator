import { Result } from '@inh-lib/common';
import { DeleteBibleDetailInput, DeleteBibleDetailOutput } from './type.delete-bible-detail';
import { GetBibleDetailInput, GetBibleDetailOutput } from './type.get-bible-detail';

export interface Repository {
  getBibleDetail(input: GetBibleDetailInput): Promise<Result<GetBibleDetailOutput>>;
  deleteBibleDetail(input: DeleteBibleDetailInput): Promise<Result<DeleteBibleDetailOutput>>;
}
