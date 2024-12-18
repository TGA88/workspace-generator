import { Result } from '@inh-lib/common';
import { CreateBibleInput, CreateBibleOutput } from './type.create-bible';
// import { GetAllAnimalTypeInput, GetAllAnimalTypeOutput } from './type.get-all-animal-type';

export interface Repository {
  // getAllAnimalType(input: GetAllAnimalTypeInput): Promise<Result<GetAllAnimalTypeOutput>>;
  createBible(input: CreateBibleInput): Promise<Result<CreateBibleOutput>>;
}
