import { UseCase } from '@inh-lib/ddd';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import { InputDTO, OutputDTO } from './dto';
import { DataParser } from '@fos-psc-webapi/bible-factory-core';
import {
  InputModel,
  OutputModel,
  Failures,
  Repository,
  DuplicateBibleOutput,
  CheckBibleStatusOutput,
  // GetAllAnimalTypeOutput,

} from '@fos-psc-webapi/bible-factory-core/command/duplicate-bible';

type Response = Either<Failures.ParseFail | Failures.DuplicateFail, Result<OutputDTO>>;

export class Handler implements UseCase<InputDTO, Promise<Response>> {
  private repository: Repository;
  private mapper: DataParser<InputDTO, InputModel>;
  private mapperSuccess: DataParser<OutputModel, OutputDTO>;
  private logger: InhLogger;

  constructor(
    repository: Repository,
    mapper: DataParser<InputDTO, InputModel>,
    mapperSuccess: DataParser<OutputModel, OutputDTO>,
    logger: InhLogger,
  ) {
    this.repository = repository;
    this.mapper = mapper;
    this.mapperSuccess = mapperSuccess;
    this.logger = logger;
  }


  async execute(req: InputDTO): Promise<Response> {
    const parseDTOToModelsOrError = this.mapper(req);
    if (parseDTOToModelsOrError.isFailure) {
      return left(new Failures.ParseFail());
    }
    const inputModels = parseDTOToModelsOrError.getValue() as InputModel;
    //  check status
    const checkStatusOrError = await this.repository.checkStatus({
      id: inputModels.id
    })
    if (checkStatusOrError.isFailure) {
      const error = checkStatusOrError.errorValue() as unknown as string
      this.logger.error(`error in checkStatusOrError: ${error}`)
      return left(new Failures.GetFail(error));
    }
    const checkStatusResult = checkStatusOrError.getValue() as CheckBibleStatusOutput

    if (checkStatusResult.status === 'CANCEL') {
      this.logger.error(`error in checkStatusResult.status`)
      return left(new Failures.StatusFail('status Is "CANCEL"'))
    }



    const duplicateBibleOrError = await this.repository.duplicateBible({
      id: inputModels.id,
      animalType: inputModels.animalType,
      year: inputModels.year,
      createBy: inputModels.uid,
      bibleStatus: 'DARFT',

    });
    if (duplicateBibleOrError.isFailure) {
      const error = duplicateBibleOrError.errorValue() as unknown as string;
      this.logger.error(`error in duplicateBibleOrError: ${error}`);
      return left(new Failures.DuplicateFail(error));
    }

    const duplicateBibleResult = duplicateBibleOrError.getValue() as DuplicateBibleOutput;



    const parseToDTO = this.mapperSuccess({
      id: duplicateBibleResult.id,
    });
    const successDTO = parseToDTO.getValue();
    return right(Result.ok(successDTO));
  }


  //เช็คว่า year + animalType ไม่ซ้ำกัน
  // checkDuplicateYearAndAnimalType(
  //   animalType: { animalTypeCode: string; animalTypeName: string }[],
  //   input: InputModel,
  // ): boolean {
  //   const animalTypeSet = new Set(animalType.map((item) => JSON.stringify(item)));
  //   return input.animalType.some((item) => animalTypeSet.has(JSON.stringify(item)));
  // }

}
