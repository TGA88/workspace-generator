import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
  EditBibleDetailOutput,
  Failures,
  GetBibleDetailOutput,
  InputModel,
  OutputModel,
  Repository,
} from '@fos-psc-webapi/bible-factory-core/command/edit-bible-detail';
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

    const editBibleDetailOrError = await this.repository.editBibleDetail({
      id: inputModels.id,
      items: inputModels.items,
      updateBy: inputModels.uid,
    });
    if (editBibleDetailOrError.isFailure) {
      const error = editBibleDetailOrError.errorValue() as unknown as string;
      this.logger.error(`error in editBibleDetailOrError: ${error}`);
      return left(new Failures.UpdateFail(error));
    }
    const editBibleDetailResult = editBibleDetailOrError.getValue() as EditBibleDetailOutput;

    const parseToDTO = this.mapperSuccess({
      id: editBibleDetailResult.id,
    });
    const successDTO = parseToDTO.getValue();
    return right(Result.ok(successDTO));
  }
}
