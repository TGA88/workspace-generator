import {
  CheckBibleStatusInput,
  CheckBibleStatusOutput,
  // GetAllAnimalTypeInput,
  // GetAllAnimalTypeOutput,
  DuplicateBibleInput,
  DuplicateBibleOutput,
  Repository,
} from '@gu-example-system/exm-api-core/command/duplicate-bible';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@exm-data-store-prisma/dbclient';

// สำหรับต่อ database
export class DuplicateBibleRepo implements Repository {
  private logger: InhLogger;
  private client: PrismaClient;

  constructor(client: PrismaClient, logger: InhLogger) {
    this.client = client;
    this.logger = logger;
  }
  async checkStatus(props: CheckBibleStatusInput): Promise<Result<CheckBibleStatusOutput>> {
    try {
      this.logger.info("checkStatus: execute bIBLE.findUnique")
      const raw = await this.client.bIBLE.findUnique({
        where: { ID: props.id },
        select: {
          BIBLE_STATUS: true
        }
      })
      if (!raw) {
        throw new Error('Prescription not found!')
      }

      return Result.ok({
        status: raw.BIBLE_STATUS as string,
      });
    } catch (error) {
      return Result.fail(error)
    }
  }

  async duplicateBible(props: DuplicateBibleInput): Promise<Result<DuplicateBibleOutput>> {
    try {
      const findDataForDup = await this.client.bIBLE.findUnique({
        where: {
          ID: props.id
        },
      })
      // create mom
      const raw = await this.client.bIBLE.create({
        data: {
          COUNTRY_CODE: findDataForDup?.COUNTRY_CODE,
          COUNTRY_NAME: findDataForDup?.COUNTRY_NAME,
          YEAR: props.year,
          SPECIES_CODE: findDataForDup?.SPECIES_CODE as string,
          SPECIES_NAME: findDataForDup?.SPECIES_NAME,
          CREATE_AT: new Date(),
          CREATE_BY: props.createBy,
          REMARKS: findDataForDup?.REMARKS,
          // UPDATE_BY:props.createBy,
          BIBLE_STATUS: 'DRAFT',
          STATUS: 'ACTIVE',
          MEDICINE_TYPE_CODE: findDataForDup?.MEDICINE_TYPE_CODE,
          MEDICINE_TYPE_NAME: findDataForDup?.MEDICINE_TYPE_NAME,
        },
      });


      const findDataDetail = await this.client.bIBLE_DETAIL.findMany({
        where: {
          BIBLE_ID: findDataForDup?.ID
        },
      })
      for (const i of findDataDetail) {
        const rawDetail = await this.client.bIBLE_DETAIL.create({
          data: {
            BIBLE_ID: raw.ID,
            COUNTRY_CODE: i.COUNTRY_CODE,
            SPECIES_CODE: i.SPECIES_CODE,
            MEDICINE_CODE: i?.MEDICINE_CODE,
            MEDICINE_GROUP: i?.MEDICINE_GROUP,
            MEDICINE_TYPE: i?.MEDICINE_TYPE as string,
            STATUS: i.STATUS,
            CREATE_AT: new Date(),
            CREATE_BY: props.createBy,
          },
        });
        if (!rawDetail) {
          throw new Error('Create Bible Detail Fail');
        }
        // console.log('rawDetail', rawDetail);
        const findMedId = await this.client.mAS_MEDICINE.findFirst({
          where: {
            MEDICINE_CODE: i.MEDICINE_CODE
          },
          select: {
            ID: true
          }
        })
        await this.client.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.create({
          data: {
            BIBLE_DETAIL_ID: rawDetail.ID as string,
            MAS_MEDICINE_ID: findMedId?.ID as string,
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

      const result: DuplicateBibleOutput = {
        id: raw.ID,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
}
