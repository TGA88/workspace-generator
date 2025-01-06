import { Result } from '@inh-lib/common';
import { DuplicateBibleOutput, DuplicateBibleInput } from './type.duplicate-bible';
// import { GetAllAnimalTypeInput, GetAllAnimalTypeOutput } from './type.check-animal-type-year';
import { CheckBibleStatusOutput, CheckBibleStatusInput } from './type.checkBibleStatus';

export interface Repository {
  duplicateBible(props: DuplicateBibleInput): Promise<Result<DuplicateBibleOutput>>;
  checkStatus(props: CheckBibleStatusInput): Promise<Result<CheckBibleStatusOutput>>;

}
