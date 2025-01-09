import {
  EditBibleInput,
  EditBibleOutput,
  // GetAllAnimalTypeInput,
  // GetAllAnimalTypeOutput,
  GetBibleDetailInput,
  GetBibleDetailOutput,
  Repository,
} from '@gu-example-system/funny-api-core/command/edit-bible';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@funny-data-store-prisma/dbclient';

// สำหรับต่อ database
export class EditBibleRepo implements Repository {
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
      };

      const result: GetBibleDetailOutput = {
        ...mapResult,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
  async editBible(props: EditBibleInput): Promise<Result<EditBibleOutput>> {
    try {
      const oldDetail = await this.client.bIBLE.findUnique({
        where: { ID: props.id },
      });

      const raw = await this.client.bIBLE.update({
        where: { ID: props.id },
        data: {
          COUNTRY_CODE: props.country.countryCode,
          COUNTRY_NAME: props.country.countryName,
          YEAR: props.year,
          SPECIES_CODE: props.species.speciesCode,
          SPECIES_NAME: props.species.speciesName,
          CREATE_BY: oldDetail?.CREATE_BY,
          UPDATE_BY: props.updateBy,
          BIBLE_STATUS: oldDetail?.BIBLE_STATUS,
          STATUS: oldDetail?.STATUS,
          MEDICINE_TYPE_CODE: props.medType?.medTypeCode,
          MEDICINE_TYPE_NAME: props.medType?.medTypeName,
          REVISED: {
            increment: 1,
          },
          REMARKS: props.remark,
        },
      });
      // ลบ animalType เก่าออก
      await this.client.bIBLE_ANIMAL_TYPE.deleteMany({
        where: { BIBLE_ID: props.id },
      });
      //สร้าง animalType ใหม่
      for (const i of props.animalType as { animalTypeCode: string; animalTypeName: string }[]) {
        // for (const i of props.animalType as string[]) {
        const rawAnimalTypeDetail = await this.client.bIBLE_ANIMAL_TYPE.create({
          data: {
            BIBLE_ID: props.id,
            ANIMAL_TYPE_CODE: i.animalTypeCode,
            ANIMAL_TYPE_NAME: i.animalTypeName,
            CREATE_BY: oldDetail?.CREATE_BY,
            UPDATE_BY: props.updateBy,
          },
        });
        if (!rawAnimalTypeDetail) {
          throw new Error('Create Animal Type Detail Fail');
        }
        // console.log('rawAnimalTypeDetail', rawAnimalTypeDetail);
      }

      const result: EditBibleOutput = {
        id: raw.ID,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
}
