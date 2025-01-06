import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
  CreateBibleOutput,
  Failures,
  // GetAllAnimalTypeOutput,
  InputModel,
  OutputModel,
  Repository,
} from '@gu-example-system/exm-api-core/command/create-bible';
import { DataParser } from '@gu-example-system/exm-api-core';

type Response = Either<Failures.CreateFail | Failures.ParseFail, Result<OutputDTO>>;

export class Handler implements UseCase<InputDTO, Promise<Response>> {
  private readonly mapper: DataParser<InputDTO, InputModel>;
  private readonly mapperSuccess: DataParser<OutputModel, OutputDTO>;
  private readonly repository: Repository;
  private readonly logger: InhLogger;

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


    const createBibleOrError = await this.repository.createBible({
      country: inputModels.country,
      year: inputModels.year,
      species: inputModels.species,
      animalType: inputModels.animalType,
      items: inputModels.items,
      medType: inputModels.medType,
      createBy: inputModels.uid,
    });
    if (createBibleOrError.isFailure) {
      const error = createBibleOrError.errorValue() as unknown as string;
      this.logger.error(`error in createBibleOrError: ${error}`);
      return left(new Failures.CreateFail(error));
    }
    const createBibleResult = createBibleOrError.getValue() as CreateBibleOutput;

    const parseToDTO = this.mapperSuccess({
      id: createBibleResult.id,
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
