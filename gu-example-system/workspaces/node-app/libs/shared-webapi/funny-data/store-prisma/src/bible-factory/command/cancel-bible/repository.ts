import {
  CancelBibleInput,
  CancelBibleOutput,
  GetBibleDetailInput,
  GetBibleDetailOutput,
  Repository,
} from '@gu-example-system/funny-api-core/command/cancel-bible';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@funny-data-store-prisma/dbclient';

// สำหรับต่อ database
export class CancelBibleRepo implements Repository {
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
          STATUS: true,
          YEAR: true,
        },
      });
      if (!raw) {
        throw new Error('Get Detail Fail');
      }

      const result: GetBibleDetailOutput = {
        id: props.id,
        bibleStatus: raw.BIBLE_STATUS,
        status: raw.STATUS as string,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
  async cancelBible(props: CancelBibleInput): Promise<Result<CancelBibleOutput>> {
    try {
      const raw = await this.client.bIBLE.update({
        where: { ID: props.id },
        data: {
          UPDATE_BY: props.updateBy,
          STATUS: 'INACTIVE',
          BIBLE_STATUS: 'CANCEL',
          CANCEL_REASON: props.cancelRemark,
          CANCEL_DATE: new Date(),
        },
      });

      const rawDetail = await this.client.bIBLE_DETAIL.findMany({
        where: { BIBLE_ID: props.id },
        select: { ID: true },
      });

      for (const i of rawDetail) {
        await this.client.bIBLE_DETAIL.update({
          where: { ID: i.ID },
          data: {
            UPDATE_BY: props.updateBy,
            STATUS: 'INACTIVE',
          },
        });
      }

      const result: CancelBibleOutput = {
        id: raw.ID,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
}
