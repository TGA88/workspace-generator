import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
  Failures,
  GetBibleDetailOutput,
  InputModel,
  OutputModel,
  Repository,
  UpdateBibleDetailStatusOutput,
} from '@fos-psc-webapi/bible-factory-core/command/update-bible-detail-status';
import { DataParser } from '@fos-psc-webapi/bible-factory-core';

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
      return left(new Failures.BibleDetailNotFound());
    }
    const getBibleDetailResult = getBibleDetailOrError.getValue() as GetBibleDetailOutput;

    if (getBibleDetailResult.bibleStatus == 'CANCEL') {
      this.logger.error(`error in getBibleDetailResult status not "DRAFT" or "PUBLISHED"`);
      return left(new Failures.CheckConditionFail('Bible status not "DRAFT" or "PUBLISHED"'));
    }

    const updateBibleDetailStatusOrError = await this.repository.updateBibleDetailStatus({
      id: inputModels.detailId,
      bibleId: inputModels.id,
      status: inputModels.status,
      updateBy: inputModels.uid,
    });
    if (updateBibleDetailStatusOrError.isFailure) {
      const error = updateBibleDetailStatusOrError.errorValue() as unknown as string;
      this.logger.error(`error in updateBibleDetailStatusOrError: ${error}`);
      return left(new Failures.UpdateFail(error));
    }
    const updateBibleDetailStatusResult = updateBibleDetailStatusOrError.getValue() as UpdateBibleDetailStatusOutput;

    const parseToDTO = this.mapperSuccess({
      detailId: updateBibleDetailStatusResult.id,
    });
    const successDTO = parseToDTO.getValue();
    return right(Result.ok(successDTO));
  }
}
