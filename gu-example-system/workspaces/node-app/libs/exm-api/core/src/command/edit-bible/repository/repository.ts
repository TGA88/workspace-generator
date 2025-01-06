import { Result } from '@inh-lib/common';
import { EditBibleInput, EditBibleOutput } from './type.edit-bible';
import { GetBibleDetailInput, GetBibleDetailOutput } from './type.get-bible-detail';
// import { GetAllAnimalTypeInput, GetAllAnimalTypeOutput } from './type.get-all-animal-type';

export interface Repository {
  // getAllAnimalType(input: GetAllAnimalTypeInput): Promise<Result<GetAllAnimalTypeOutput>>;
  getBibleDetail(input: GetBibleDetailInput): Promise<Result<GetBibleDetailOutput>>;
  editBible(input: EditBibleInput): Promise<Result<EditBibleOutput>>;
}
