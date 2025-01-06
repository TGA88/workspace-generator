import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
  Failures,
  InputModel,
  OutputModel,
  Repository,
  DeleteBibleDetailOutput,
  GetBibleDetailOutput,
} from '@gu-example-system/exm-api-core/command/delete-bible-detail';
import { DataParser } from '@gu-example-system/exm-api-core';

type Response = Either<Failures.DeleteFail | Failures.ParseFail, Result<OutputDTO>>;

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

    if (
      !getBibleDetailResult.species ||
      !getBibleDetailResult.year ||
      !getBibleDetailResult.medType ||
      getBibleDetailResult.animalType.length == 0 ||
      !getBibleDetailResult.country
    ) {
      this.logger.error(`error data not enought for delete detail`);
      return left(new Failures.CheckConditionFail('Data in Bible record not enought to delete'));
    }
    if (getBibleDetailResult.total == 1) {
      this.logger.error(`error data not enought for delete detail`);
      return left(
        new Failures.CheckConditionFail(
          'This is the last medicine in this bible, Please edit current medicine and try again.',
        ),
      );
    }

    if (getBibleDetailResult.bibleStatus !== 'DRAFT') {
      this.logger.error(`error in getBibleDetailResult status not "DRAFT"`);
      return left(new Failures.CheckConditionFail('Bible status not "DRAFT"'));
    }

    const deleteBibleDetailOrError = await this.repository.deleteBibleDetail({
      id: inputModels.detailId,
      bibleId: inputModels.id,
      updateBy: inputModels.uid,
    });
    if (deleteBibleDetailOrError.isFailure) {
      const error = deleteBibleDetailOrError.errorValue() as unknown as string;
      this.logger.error(`error in deleteBibleDetailOrError: ${error}`);
      return left(new Failures.DeleteFail(error));
    }
    const deleteBibleDetailResult = deleteBibleDetailOrError.getValue() as DeleteBibleDetailOutput;

    const parseToDTO = this.mapperSuccess({
      detailId: deleteBibleDetailResult.id,
    });
    const successDTO = parseToDTO.getValue();
    return right(Result.ok(successDTO));
  }
}
