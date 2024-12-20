import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
  Failures,
  InputModel,
  OutputModel,
  Repository,
  GetAnimalTypeOutput,
} from '@fos-psc-webapi/bible-factory-core/query/get-bible-animal-type';
import { DataParser } from 'libs/fos-psc-webapi/prescription-core';

type Response = Either<
  Failures.GetFail | Failures.ParseFail,
  // success
  Result<OutputDTO>
>;

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
    // 1.รับ input
    const parseDTOToModelsOrError = this.mapper(req);
    if (parseDTOToModelsOrError.isFailure) {
      // พ่นlog ให้เรารู้ใน api
      this.logger.error('parse fail');
      // error พ่นไปหน้าบ้าน
      return left(new Failures.ParseFail());
    }
    const inputModels = parseDTOToModelsOrError.getValue() as InputModel;
    //inputModels ใช้ต่อ db
    const getAnimalTypeOrError = await this.repository.getAnimalType({
      page: inputModels.page,
      size: inputModels.size,
      search: inputModels.search,
      speciesCode: inputModels.speciesCode,
    });
    if (getAnimalTypeOrError.isFailure) {
      // เช็ค error จาก api
      const error = getAnimalTypeOrError.errorValue() as unknown as string;
      this.logger.error(`error in getAnimalTypePrescriptionOrError: ${error}`);
      return left(new Failures.GetFail());
    }
    const getAnimalTypeResult = getAnimalTypeOrError.getValue() as GetAnimalTypeOutput;

    const parseToDTO = this.mapperSuccess({
      items: getAnimalTypeResult.items,
      total: getAnimalTypeResult.total,
    });
    const successDTO = parseToDTO.getValue();
    return right(Result.ok(successDTO));
  }
}
