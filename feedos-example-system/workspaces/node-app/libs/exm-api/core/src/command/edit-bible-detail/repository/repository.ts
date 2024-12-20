import { Result } from '@inh-lib/common';
import { EditBibleDetailInput, EditBibleDetailOutput } from './type.edit-bible-detail';
import { GetBibleDetailInput, GetBibleDetailOutput } from './type.get-bible-detail';

export interface Repository {
  getBibleDetail(input: GetBibleDetailInput): Promise<Result<GetBibleDetailOutput>>;
  editBibleDetail(input: EditBibleDetailInput): Promise<Result<EditBibleDetailOutput>>;
}
