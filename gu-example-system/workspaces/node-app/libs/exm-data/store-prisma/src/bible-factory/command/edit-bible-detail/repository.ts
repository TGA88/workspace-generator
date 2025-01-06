import {
  EditBibleDetailInput,
  EditBibleDetailOutput,
  GetBibleDetailInput,
  GetBibleDetailOutput,
  Repository,
} from '@gu-example-system/exm-api-core/command/edit-bible-detail';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@exm-data-store-prisma/dbclient';

// สำหรับต่อ database
export class EditBibleDetailRepo implements Repository {
  private logger: InhLogger;
  private client: PrismaClient;

  constructor(client: PrismaClient, logger: InhLogger) {
    this.client = client;
    this.logger = logger;
  }

  async getBibleDetail(props: GetBibleDetailInput): Promise<Result<GetBibleDetailOutput>> {
    try {
      this.logger.info("getBibleDetail: execute bIBLE.findUnique")
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

      const mapResult = {
        id: raw.ID,
        animalType: raw.BIBLE_ANIMAL_TYPE.map((d) => {
          return { animalTypeCode: d.ANIMAL_TYPE_CODE, animalTypeName: d.ANIMAL_TYPE_NAME };
        }) as { animalTypeCode: string; animalTypeName: string }[],
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
      };

      const result: GetBibleDetailOutput = {
        ...mapResult,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
  async editBibleDetail(props: EditBibleDetailInput): Promise<Result<EditBibleDetailOutput>> {
    try {
      const raw = await this.client.bIBLE_DETAIL.findMany({
        where: {
          BIBLE_ID: props.id,
        },
        select: {
          BIBLE_DETAIL_MAPPING_MAS_MEDICINE: {
            select: {
              ID: true,
              BIBLE_DETAIL_ID: true,
              MAS_MEDICINE_ID: true,
            },
          },
        },
      });

      const medId = raw.map((d) => d.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.map((m) => m.MAS_MEDICINE_ID).join(','));
      const detailId = raw.map((d) => d.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.map((m) => m.BIBLE_DETAIL_ID).join(','));

      const notUsedMed = medId.filter((data) => !props.items.some((item) => item == data));
      // console.log('notUsedMed', notUsedMed);
      if (notUsedMed.length > 0) {
        // const oldMedId = idToDeletes.map((data) => data.ID);
        const deleteId = await this.client.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.findMany({
          where: { MAS_MEDICINE_ID: { in: notUsedMed }, BIBLE_DETAIL_ID: { in: detailId } },
          select: { ID: true, BIBLE_DETAIL_ID: true },
        });
        const mapDeleteId = deleteId.map((data) => {
          return { bibleDetailMappingMedId: data.ID, detailId: data.BIBLE_DETAIL_ID };
        });
        // console.log('mapDeleteId', mapDeleteId);
        for (const data of mapDeleteId) {
          await this.client.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.delete({
            where: {
              ID: data.bibleDetailMappingMedId,
            },
          });
          await this.client.bIBLE_DETAIL.delete({
            where: {
              ID: data.detailId,
            },
          });
        }
      }
      const newMed = props.items.filter((data) => !medId.some((prop) => prop == data));
      // console.log('newMed', newMed);
      if (newMed.length > 0) {
        const detail = await this.client.bIBLE.findUnique({
          where: { ID: props.id },
        });
        for (const data of newMed) {
          const medDetail = await this.client.mAS_MEDICINE.findUnique({
            where: { ID: data },
            select: {
              MEDICINE_CODE: true,
              MEDICINE_GROUP: true,
              MEDICINE_TYPE_CODE: true,
            },
          });
          const newDetail = await this.client.bIBLE_DETAIL.create({
            data: {
              BIBLE_ID: props.id,
              SPECIES_CODE: detail?.SPECIES_CODE,
              COUNTRY_CODE: detail?.COUNTRY_CODE,
              CREATE_BY: props.updateBy,
              STATUS: detail?.STATUS,
              MEDICINE_CODE: medDetail?.MEDICINE_CODE,
              MEDICINE_GROUP: medDetail?.MEDICINE_GROUP,
              MEDICINE_TYPE: medDetail?.MEDICINE_TYPE_CODE,
            },
          });
          await this.client.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.create({
            data: {
              BIBLE_DETAIL_ID: newDetail.ID,
              MAS_MEDICINE_ID: data,
              CREATE_BY: props.updateBy,
            },
          });
        }
      }

      await this.client.bIBLE.update({
        where: {
          ID: props.id,
        },
        data: {
          UPDATE_BY: props.updateBy,
        },
      });

      const result: EditBibleDetailOutput = {
        id: props.id,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
}
