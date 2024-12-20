import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
  Failures,
  GetMedicineOutput,
  InputModel,
  OutputModel,
  Repository,
} from '@feedos-example-system/exm-api-core/query/get-bible-medicine';
import { DataParser } from '@feedos-example-system/exm-api-core';

type Response = Either<Failures.GetFail | Failures.ParseFail, Result<OutputDTO>>;

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
      this.logger.error('parse fail');
      return left(new Failures.ParseFail());
    }
    const inputModels = parseDTOToModelsOrError.getValue() as InputModel;

    const getMedicineOrError = await this.repository.getMedicine({
      page: inputModels.page as number,
      size: inputModels.size as number,
      search: inputModels.search,
      countryCode: inputModels.countryCode,
      medicineTypeCode: inputModels.medicineTypeCode,
      speciesCode: inputModels.speciesCode,
    });
    if (getMedicineOrError.isFailure) {
      const error = getMedicineOrError.errorValue() as unknown as string;
      this.logger.error(`error in getCountryOrError: ${error}`);
      return left(new Failures.GetFail());
    }
    const getMedicineResult = getMedicineOrError.getValue() as GetMedicineOutput;

    const parseToDTO = this.mapperSuccess({
      items: getMedicineResult.items,
      total: getMedicineResult.total,
    });
    const successDTO = parseToDTO.getValue();
    return right(Result.ok(successDTO));
  }
}
