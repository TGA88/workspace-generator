import { Result } from '@inh-lib/common';
import { UpdateBibleDetailStatusInput, UpdateBibleDetailStatusOutput } from './type.update-bible-detail-status';
import { GetBibleDetailInput, GetBibleDetailOutput } from './type.get-bible-detail';

export interface Repository {
  getBibleDetail(input: GetBibleDetailInput): Promise<Result<GetBibleDetailOutput>>;
  updateBibleDetailStatus(input: UpdateBibleDetailStatusInput): Promise<Result<UpdateBibleDetailStatusOutput>>;
}
