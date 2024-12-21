import {
  CreateBibleInput,
  CreateBibleOutput,
  // GetAllAnimalTypeInput,
  // GetAllAnimalTypeOutput,
  Repository,
} from '@feedos-example-system/exm-api-core/command/create-bible';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@exm-data-store-prisma/dbclient';

// สำหรับต่อ database
export class CreateBibleRepo implements Repository {
  private logger: InhLogger;
  private client: PrismaClient;

  constructor(client: PrismaClient, logger: InhLogger) {
    this.client = client;
    this.logger = logger;
  }

  async createBible(props: CreateBibleInput): Promise<Result<CreateBibleOutput>> {
    try {
      this.logger.info("createBible: execute bIBLE.create ")
      const raw = await this.client.bIBLE.create({
        data: {
          COUNTRY_CODE: props.country.countryCode,
          COUNTRY_NAME: props.country.countryName,
          YEAR: props.year,
          SPECIES_CODE: props.species.speciesCode,
          SPECIES_NAME: props.species.speciesName,
          CREATE_AT: new Date(),
          CREATE_BY: props.createBy,
          BIBLE_STATUS: 'DRAFT',
          STATUS: 'ACTIVE',
          MEDICINE_TYPE_CODE: props.medType?.medTypeCode,
          MEDICINE_TYPE_NAME: props.medType?.medTypeName,
        },
      });
      // console.log('raw', raw);

      for (const i of props.items) {
        const medDetail = await this.client.mAS_MEDICINE.findUnique({
          where: {
            ID: i,
            AND: {
              STATUS: 'ACTIVE',
            },
          },
          select: { MEDICINE_GROUP: true, MEDICINE_TYPE_CODE: true, MEDICINE_CODE: true },
        });

        const rawDetail = await this.client.bIBLE_DETAIL.create({
          data: {
            BIBLE_ID: raw.ID,
            COUNTRY_CODE: raw.COUNTRY_CODE,
            SPECIES_CODE: raw.SPECIES_CODE,
            MEDICINE_CODE: medDetail?.MEDICINE_CODE,
            MEDICINE_GROUP: medDetail?.MEDICINE_GROUP,
            MEDICINE_TYPE: medDetail?.MEDICINE_TYPE_CODE,
            STATUS: raw.STATUS,
            CREATE_AT: new Date(),
            CREATE_BY: props.createBy,
          },
        });
        if (!rawDetail) {
          throw new Error('Create Bible Detail Fail');
        }
        // console.log('rawDetail', rawDetail);

        await this.client.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.create({
          data: {
            BIBLE_DETAIL_ID: rawDetail.ID,
            MAS_MEDICINE_ID: i,
            CREATE_AT: new Date(),
            CREATE_BY: props.createBy,
          },
        });
        // console.log('rawMapDetailWithMed', rawMapDetailWithMed);
      }
      for (const i of props.animalType as { animalTypeCode: string; animalTypeName: string }[]) {
        // for (const i of props.animalType as string[]) {
        const rawAnimalTypeDetail = await this.client.bIBLE_ANIMAL_TYPE.create({
          data: {
            BIBLE_ID: raw.ID,
            ANIMAL_TYPE_CODE: i.animalTypeCode,
            ANIMAL_TYPE_NAME: i.animalTypeName,
            CREATE_AT: new Date(),
            CREATE_BY: props.createBy,
          },
        });
        if (!rawAnimalTypeDetail) {
          throw new Error('Create Animal Type Detail Fail');
        }
        // console.log('rawAnimalTypeDetail', rawAnimalTypeDetail);
      }

      const result: CreateBibleOutput = {
        id: raw.ID,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
}
