import {
  DeleteBibleDetailInput,
  DeleteBibleDetailOutput,
  GetBibleDetailInput,
  GetBibleDetailOutput,
  Repository,
} from '@gu-example-system/exm-api-core/command/delete-bible-detail';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@exm-data-store-prisma/dbclient';

// สำหรับต่อ database
export class DeleteBibleDetailRepo implements Repository {
  private logger: InhLogger;
  private client: PrismaClient;

  constructor(client: PrismaClient, logger: InhLogger) {
    this.client = client;
    this.logger = logger;
  }
  async getBibleDetail(props: GetBibleDetailInput): Promise<Result<GetBibleDetailOutput>> {
    try {
      this.logger.info("getBibleDetail: execute bIBLE.findUnique ")
      const raw = await this.client.bIBLE.findUnique({
        where: {
          ID: props.id,
        },
        select: {
          ID: true,
          BIBLE_STATUS: true,
          CANCEL_REASON: true,
          COUNTRY_CODE: true,
          COUNTRY_NAME: true,
          MEDICINE_TYPE_CODE: true,
          MEDICINE_TYPE_NAME: true,
          REMARKS: true,
          SPECIES_CODE: true,
          SPECIES_NAME: true,
          STATUS: true,
          YEAR: true,
          UPDATE_AT: true,
          UPDATE_BY: true,
          CREATE_BY: true,
          BIBLE_ANIMAL_TYPE: {
            where: {
              BIBLE_ID: props.id,
            },
            select: {
              ANIMAL_TYPE_CODE: true,
              ANIMAL_TYPE_NAME: true,
            },
          },
        },
      });
      if (!raw) {
        throw new Error('Get Detail Fail');
      }

      const totalDetail = await this.client.bIBLE_DETAIL.count({
        where: {
          BIBLE_ID: props.id,
        },
      });

      const mapResult = {
        id: raw.ID,
        animalType: raw.BIBLE_ANIMAL_TYPE.map((d) => {
          return { animalTypeCode: d.ANIMAL_TYPE_CODE, animalTypeName: d.ANIMAL_TYPE_NAME };
        }) as { animalTypeCode: string; animalTypeName: string }[],
        // animalType: raw.BIBLE_ANIMAL_TYPE.map((d) => {return {animalTypeCode: d.ANIMAL_TYPE_CODE,animalTypeName: d.ANIMAL_TYPE_NAME}}),
        country: {
          countryCode: raw.COUNTRY_CODE as string,
          countryName: raw.COUNTRY_NAME as string,
        },
        remark: raw.REMARKS as string,
        species: {
          speciesCode: raw.SPECIES_CODE as string,
          speciesName: raw.SPECIES_NAME as string,
        },
        year: raw.YEAR,
        medType: {
          medTypeCode: raw.MEDICINE_TYPE_CODE as string,
          medTypeName: raw.MEDICINE_TYPE_NAME as string,
        },
        bibleStatus: raw.BIBLE_STATUS,
        total: totalDetail,
      };

      const result: GetBibleDetailOutput = {
        ...mapResult,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
  async deleteBibleDetail(props: DeleteBibleDetailInput): Promise<Result<DeleteBibleDetailOutput>> {
    try {
      const mappingDetailMed = await this.client.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.findFirst({
        where: { BIBLE_DETAIL_ID: props.id },
        select: { ID: true },
      });

      await this.client.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.delete({
        where: { ID: mappingDetailMed?.ID },
      });

      await this.client.bIBLE_DETAIL.delete({
        where: { ID: props.id },
      });

      await this.client.bIBLE.update({
        where: { ID: props.bibleId },
        data: {
          UPDATE_BY: props.updateBy,
        },
      });

      const result: DeleteBibleDetailOutput = {
        id: props.id,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
}
