import { Result } from '@inh-lib/common';
import { GetAnimalTypeOutput, GetAnimalTypeInput } from './type.get-animal-type';

export interface Repository {
  getAnimalType(input: GetAnimalTypeInput): Promise<Result<GetAnimalTypeOutput>>;
}
