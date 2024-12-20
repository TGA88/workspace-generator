import { UseCase } from '@inh-lib/ddd';
import { InputDTO, OutputDTO } from './dto';
import { Either, InhLogger, Result, left, right } from '@inh-lib/common';
import {
  Failures,
  GetBibleDetailOutput,
  GetCreaterEmailOutput,
  InputModel,
  OutputModel,
  Repository,
  GetIsPublishedOutput,
} from '@fos-psc-webapi/bible-factory-core/command/publish-bible';
import { DataParser } from '@fos-psc-webapi/bible-factory-core';
import { FosPscNotifyAxiosClient, publishBibleHTMLRender } from '@fos-pscnotify-webapi/pscnotify-api-client';

type Response = Either<Failures.UpdateFail | Failures.ParseFail, Result<OutputDTO>>;

export class Handler implements UseCase<InputDTO, Promise<Response>> {
  private mapper: DataParser<InputDTO, InputModel>;
  private mapperSuccess: DataParser<OutputModel, OutputDTO>;
  private repository: Repository;
  private logger: InhLogger;
  private notifyClient: FosPscNotifyAxiosClient;

  constructor(
    mapper: DataParser<InputDTO, InputModel>,
    mapperSuccess: DataParser<OutputModel, OutputDTO>,
    repository: Repository,
    logger: InhLogger,
    notifyClient: FosPscNotifyAxiosClient,
  ) {
    this.mapper = mapper;
    this.mapperSuccess = mapperSuccess;
    this.repository = repository;
    this.logger = logger;
    this.notifyClient = notifyClient;
  }
  async execute(req: InputDTO): Promise<Response> {
    const parseDTOToModelsOrError = this.mapper(req);
    if (parseDTOToModelsOrError.isFailure) {
      this.logger.error('parse fail');
      return left(new Failures.ParseFail());
    }
    const inputModels = parseDTOToModelsOrError.getValue() as InputModel;
    //เช็ค bible detail
    const getBibleDetailOrError = await this.repository.getBibleDetail({
      bibleId: inputModels.id,
    });
    if (getBibleDetailOrError.isFailure) {
      const error = getBibleDetailOrError.errorValue() as unknown as string;
      this.logger.error(`error in getBibleDetailOrError: ${error}`);
      return left(new Failures.UpdateFail(error));
    }
    const getBibleDetailResult = getBibleDetailOrError.getValue() as GetBibleDetailOutput;

    //check med,year,species,animalType not publish
    const getIsPublishedOrError = await this.repository.getIsPublished({
      animalTypeCode: getBibleDetailResult.bibleAnimalType.map((data) => data.animalTypeCode),
      medTypeCode: getBibleDetailResult.medTypeCode,
      speciesCode: getBibleDetailResult.speciesCode,
      year: getBibleDetailResult.year,
    });
    if (getIsPublishedOrError.isFailure) {
      const error = getIsPublishedOrError.errorValue() as unknown as string;
      this.logger.error(`error in getIsPublishedOrError: ${error}`);
      return left(new Failures.UpdateFail(error));
    }
    const getIsPublishedResult = getIsPublishedOrError.getValue() as GetIsPublishedOutput;

    //กรณียังไม่ publish
    if (getBibleDetailResult.bibleStatus !== 'PUBLISHED') {
      if (getIsPublishedResult.items.length > 0) {
        this.logger.error(`error bible detail already has published`);
        return left(new Failures.UpdateFail('There is already have BIBLE with this same Year and Animal Type'));
      }
      //เช็คข้อมูลครบเงื่อนไขที่จะสามารถ publish ได้
      if (
        !getBibleDetailResult.speciesCode ||
        !getBibleDetailResult.year ||
        !getBibleDetailResult.medTypeCode ||
        getBibleDetailResult.bibleDetail.length == 0 ||
        getBibleDetailResult.bibleAnimalType.length == 0
      ) {
        this.logger.error(`error data not enought for PUBLISH`);
        return left(new Failures.UpdateFail('Data in Bible record not enought to change BIBLE_STATUS to PUBLISHED'));
      }
      //เช็ค BIBLE_STATUS ปัจจุบันต้องไม่ใช่ CANCEL หรือ PUBLISHED
      if (getBibleDetailResult.bibleStatus === 'CANCEL') {
        this.logger.error(`error BIBLE_STATUS is CANCEL or PUBLISHED`);
        return left(new Failures.UpdateFail('BIBLE_STATUS is CANCEL or PUBLISHED'));
      }

      //เปลี่ยนสถานะ bible เป็น publish
      const changeBibleStatusOrError = await this.repository.changeBibleStatus({
        bibleId: inputModels.id,
        status: 'PUBLISHED',
        veterinarianCode: inputModels.veterinarianCode,
        uid: inputModels.uid,
      });
      if (changeBibleStatusOrError.isFailure) {
        const error = changeBibleStatusOrError.errorValue() as unknown as string;
        this.logger.error(`error in changeBibleStatusOrError: ${error}`);
        return left(new Failures.UpdateFail(error));
      }
    }

    //หา email ของคนสร้าง
    const getCreaterEmailOrError = await this.repository.getCreaterEmail({
      accountUsername: getBibleDetailResult.createBy, //ต้องมี createBy ตั้งแต่ตอนสร้าง
    });
    if (getCreaterEmailOrError.isFailure) {
      const error = getCreaterEmailOrError.errorValue() as unknown as string;
      this.logger.error(`error in getCreaterEmailOrError: ${error}`);
      return left(new Failures.UpdateFail(error));
    }
    const getCreaterEmailResult = getCreaterEmailOrError.getValue() as GetCreaterEmailOutput;

    //send email notify creater
    const sendEmailOrError = await this.notifyClient.sendEmail({
      subject: `รายการ Bible Factory ID: ${inputModels.id} ของคุณถูก Publish สำเร็จ`,
      template: publishBibleHTMLRender({
        bibleId: inputModels.id,
        bibleStatus: 'PUBLISH',
        year: getBibleDetailResult.year,
        species: getBibleDetailResult.speciesName,
        type: getBibleDetailResult.bibleAnimalType.map((data) => data.animalTypeName).join(','),
      }),
      to: [getCreaterEmailResult.email],
    });
    if (sendEmailOrError.isFailure) {
      const error = sendEmailOrError.errorValue() as unknown as string;
      this.logger.error(`error in sendEmailOrError: ${error}`);
      return left(new Failures.UpdateFail(error));
    }

    const parseToDTO = this.mapperSuccess({
      id: inputModels.id,
    });
    const successDTO = parseToDTO.getValue();
    return right(Result.ok(successDTO));
  }
}
