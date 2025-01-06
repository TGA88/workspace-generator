import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
    Failures,
    InputModel,
    OutputModel,
    Repository,
    GetDetailBibleOutput,
    GetBibleDetailOfBibleOutPut
} from '@gu-example-system/exm-api-core/query/view-bible-detail';
import { DataParser } from '@gu-example-system/exm-api-core';

type Response = Either<
    Failures.GetFail |
    Failures.ParseFail,
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
        const getBibleOrError = await this.repository.getDetailBible({
            id: inputModels.id,

        })
        if (getBibleOrError.isFailure) {
            const error = getBibleOrError.errorValue() as unknown as string
            this.logger.error(`error in getBibleOrError: ${error}`)
            return left(new Failures.GetFail());
        }
        const getResultBible = getBibleOrError.getValue() as GetDetailBibleOutput
        // ---------------
        const getBibleOfItemsOrError = await this.repository.getBibleDetailOfItems({
            id: inputModels.id,
            page: inputModels.page as number,
            size: inputModels.size as number,
            search: inputModels.search
        })
        if (getBibleOfItemsOrError.isFailure) {
            const error = getBibleOfItemsOrError.errorValue() as unknown as string
            this.logger.error(`error in getBibleOfItemsOrError: ${error}`)
            return left(new Failures.GetFail());
        }
        const bibleDetailOfItems = getBibleOfItemsOrError.getValue() as GetBibleDetailOfBibleOutPut


        const parseToDTO = this.mapperSuccess({
            ...getResultBible,
            items: bibleDetailOfItems.items,
            total: bibleDetailOfItems.total,
        });
        const successDTO = parseToDTO.getValue()
        return right(Result.ok(successDTO));
    }
}
