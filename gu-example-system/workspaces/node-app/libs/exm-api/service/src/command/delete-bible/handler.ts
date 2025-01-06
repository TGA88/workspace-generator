import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
  DeleteBibleInput,
  CheckBbibleStatusOutput,
  Failures,
  InputModel,
  OutputModel,
  Repository,
} from '@gu-example-system/exm-api-core/command/delete-bible';
import { DataParser } from '@gu-example-system/exm-api-core';

type Response = Either<
  Failures.DeleteFail |
  Failures.GetFail |
  Failures.ParseFail,
  Result<OutputDTO>
>;

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
    const checkBibleStatusOrError = await this.repository.checkBibleStatus({
      id: inputModels.id
    })
    // check fail
    if (checkBibleStatusOrError.isFailure) {
      const error = checkBibleStatusOrError.errorValue() as unknown as string
      this.logger.error(`error in checkBibleStatusOrError: ${error}`)
      return left(new Failures.GetFail(error));
    }
    //  check status
    const checkBibleStatusResult = checkBibleStatusOrError.getValue() as CheckBbibleStatusOutput
    console.log('')
    if (checkBibleStatusResult.status !== 'DRAFT') {
      this.logger.error(`error in checkBibleStatusResult.status`)
      return left(new Failures.DeleteFail('status not "DRAFT"'))
    }



    const deletePrescriptionDetailOrError = await this.repository.deleteBible({
      id: inputModels.id
    })
    if (deletePrescriptionDetailOrError.isFailure) {
      const error = deletePrescriptionDetailOrError.errorValue() as unknown as string
      this.logger.error(`error in deletePrescriptionDetailOrError: ${error}`)
      return left(new Failures.DeleteFail(error));
    }
    const createResult = deletePrescriptionDetailOrError.getValue() as DeleteBibleInput

    const parseToDTO = this.mapperSuccess({
      id: createResult.id
    });
    const successDTO = parseToDTO.getValue()
    return right(Result.ok(successDTO));
  }
}
