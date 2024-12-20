import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
  EditBibleOutput,
  Failures,
  // GetAllAnimalTypeOutput,
  GetBibleDetailOutput,
  InputModel,
  OutputModel,
  Repository,
} from '@feedos-example-system/exm-api-core/command/edit-bible';
import { DataParser } from '@feedos-example-system/exm-api-core';

type Response = Either<Failures.UpdateFail | Failures.ParseFail | Failures.GetFail, Result<OutputDTO>>;

export class Handler implements UseCase<InputDTO, Promise<Response>> {
  private mapper: DataParser<InputDTO, InputModel>;
  private mapperSuccess: DataParser<OutputModel, OutputDTO>;
  private repository: Repository;
  private logger: InhLogger;

  constructor(
    mapper: DataParser<InputDTO, InputModel>,
    mapperSuccess: DataParser<OutputModel, OutputDTO>,
    repository: Repository,
    logger: InhLogger,
  ) {
    this.mapper = mapper;
    this.mapperSuccess = mapperSuccess;
    this.repository = repository;
    this.logger = logger;
  }
  async execute(req: InputDTO): Promise<Response> {
    const parseDTOToModelsOrError = this.mapper(req);
    if (parseDTOToModelsOrError.isFailure) {
      this.logger.error('parse fail');
      return left(new Failures.ParseFail());
    }

    const inputModels = parseDTOToModelsOrError.getValue() as InputModel;

    const getBibleDetailOrError = await this.repository.getBibleDetail({
      id: inputModels.id,
    });
    if (getBibleDetailOrError.isFailure) {
      const error = getBibleDetailOrError.errorValue() as unknown as string;
      this.logger.error(`error in checkBibleDetailOrError: ${error}`);
      return left(new Failures.BibleDetailNotFound());
    }
    const getBibleDetailResult = getBibleDetailOrError.getValue() as GetBibleDetailOutput;

    if (getBibleDetailResult.bibleStatus !== 'DRAFT') {
      this.logger.error(`error in getBibleDetailResult status not "DRAFT"`);
      return left(new Failures.CheckConditionFail('Bible status not "DRAFT"'));
    }



    const editBibleOrError = await this.repository.editBible({
      id: inputModels.id,
      remark: inputModels.remark,
      updateBy: inputModels.uid,
      country: inputModels.country,
      year: inputModels.year,
      species: inputModels.species,
      animalType: inputModels.animalType,
      medType: inputModels.medType,
    });
    if (editBibleOrError.isFailure) {
      const error = editBibleOrError.errorValue() as unknown as string;
      this.logger.error(`error in editBibleOrError: ${error}`);
      return left(new Failures.UpdateFail(error));
    }
    const editBibleResult = editBibleOrError.getValue() as EditBibleOutput;

    const parseToDTO = this.mapperSuccess({
      id: editBibleResult.id,
      // id: 'test',
    });
    const successDTO = parseToDTO.getValue();
    return right(Result.ok(successDTO));
  }

  //เช็คว่า year + animalType ไม่ซ้ำกัน
  // checkDuplicateYearAndAnimalType(
  //   animalType: { animalTypeCode: string; animalTypeName: string }[],
  //   input: InputModel,
  // ): boolean {
  //   const animalTypeSet = animalType.map((item) => item.animalTypeCode);
  //   const inputAnimalType = input.animalType.map((data) => data.animalTypeCode);
  //   return inputAnimalType.some((item) => animalTypeSet.includes(item));
  // }
}
