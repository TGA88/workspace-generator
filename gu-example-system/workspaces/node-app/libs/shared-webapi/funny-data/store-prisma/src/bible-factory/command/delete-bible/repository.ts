import {
  CheckBibleStatusInput,
  CheckBbibleStatusOutput,
  DeleteBibleInput,
  DeleteBibleOutput,
  // HasPrescriptionDetailInput,
  // HasPrescriptionDetailOutput,
  Repository,
} from '@gu-example-system/funny-api-core/command/delete-bible';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@funny-data-store-prisma/dbclient';

export class DeleteBibleRepo implements Repository {
  private logger: InhLogger;
  private client: PrismaClient;

  constructor(client: PrismaClient, logger: InhLogger) {
    this.client = client;
    this.logger = logger;
  }
  async checkBibleStatus(props: CheckBibleStatusInput): Promise<Result<CheckBbibleStatusOutput>> {
    try {
      this.logger.info("checkBibleStatus: execute bIBLE.findUnique")
      const raw = await this.client.bIBLE.findUnique({
        where: { ID: props.id },
        select: {
          BIBLE_STATUS: true
        }
      })
      if (!raw) {
        throw new Error('Bible not found!')
      }

      return Result.ok({
        status: raw.BIBLE_STATUS,
      });
    } catch (error) {
      return Result.fail(error)
    }
  }
  async deleteBible(props: DeleteBibleInput): Promise<Result<DeleteBibleOutput>> {
    try {
      await this.client.$transaction(async (t) => {

        const checkAnimalRecord = await t.bIBLE_ANIMAL_TYPE.findMany({
          where: {
            BIBLE_ID: props.id
          },
        })
        if (checkAnimalRecord) {
          const mapIdToDelete = checkAnimalRecord.map((data) => {
            return {
              ID: data.ID,
            };
          });
          for (const items of mapIdToDelete) {
            await t.bIBLE_ANIMAL_TYPE.delete({
              where: {
                ID: items.ID,
              },
            });
          }
        }


        const checkBibleDetailForMedRecord = await t.bIBLE_DETAIL.findMany({
          where: {
            BIBLE_ID: props.id
          },
          select: {
            BIBLE_DETAIL_MAPPING_MAS_MEDICINE: {
              select: {
                ID: true
              }
            }
          }
        })
        console.log('checkBibleDetailForMedRecord', JSON.stringify(checkBibleDetailForMedRecord, null, 4))
        if (checkBibleDetailForMedRecord.length > 0) {
          const mapIdToDelete = checkBibleDetailForMedRecord.map((data) => {
            return {
              ID: data.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.map((items) => items.ID).join(','),
            };

          });
          for (const items of mapIdToDelete) {
            // console.log('items', items.ID)
            await t.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.delete({
              where: {
                ID: items.ID,
              },
            });
          }
        }


        const checkBibleDetailRecord = await t.bIBLE_DETAIL.findMany({
          where: {
            BIBLE_ID: props.id
          },
        })
        if (checkBibleDetailRecord) {
          const mapIdToDelete = checkBibleDetailRecord.map((data) => {
            return {
              ID: data.ID,
            };
          });
          for (const items of mapIdToDelete) {
            await t.bIBLE_DETAIL.delete({
              where: {
                ID: items.ID,
              },
            });
          }
        }

        // ลบแม่
        console.log('props.id', props.id)
        const checkRecordExist = await t.bIBLE.findUnique({
          where: {
            ID: props.id
          }, select: {
            ID: true
          }
        })
        console.log('checkRecordExist', checkRecordExist)
        if (!checkRecordExist) {
          throw new Error('bible  record not found')
        }

        await t.bIBLE.delete({
          where: {
            ID: props.id
          }, select: {
            ID: true
          }
        })
      })
      const result: DeleteBibleOutput = {
        id: props.id
      }
      console.log('result', result)
      return Result.ok(result)
    } catch (error) {
      return Result.fail(error)
    }
  }


}
