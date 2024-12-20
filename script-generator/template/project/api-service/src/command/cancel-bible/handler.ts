import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
  Failures,
  GetBibleDetailOutput,
  InputModel,
  OutputModel,
  Repository,
  CancelBibleOutput,
} from '@feedos-example-system/exm-api-core/command/cancel-bible';
import { DataParser } from '@feedos-example-system/exm-api-core';

type Response = Either<Failures.UpdateFail | Failures.ParseFail, Result<OutputDTO>>;

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
      this.logger.error(`error in getBibleDetailOrError: ${error}`);
      return left(new Failures.GetFail());
    }
    const getBibleDetailResult = getBibleDetailOrError.getValue() as GetBibleDetailOutput;

    if (getBibleDetailResult.bibleStatus != 'PUBLISHED') {
      this.logger.error(`error in getBibleDetailResult status not "PUBLISHED"`);
      return left(new Failures.CheckConditionFail('Bible status not "PUBLISHED"'));
    }

    const cancelBibleOrError = await this.repository.cancelBible({
      id: inputModels.id,
      cancelRemark: inputModels.cancelRemark,
      updateBy: inputModels.uid,
    });
    if (cancelBibleOrError.isFailure) {
      const error = cancelBibleOrError.errorValue() as unknown as string;
      this.logger.error(`error in cancelBibleOrError: ${error}`);
      return left(new Failures.UpdateFail(error));
    }
    const cancelBibleResult = cancelBibleOrError.getValue() as CancelBibleOutput;

    const parseToDTO = this.mapperSuccess({
      id: cancelBibleResult.id,
    });
    const successDTO = parseToDTO.getValue();
    return right(Result.ok(successDTO));
  }
}
