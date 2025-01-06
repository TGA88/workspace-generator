import {
  GetAnimalTypeInput,
  GetAnimalTypeOutput,
  Items,
  Repository,
} from '@gu-example-system/exm-api-core/query/get-bible-animal-type';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@exm-data-store-prisma/dbclient';

// สำหรับต่อ database
export class GetAnimalTypeBibleRepo implements Repository {
  private logger: InhLogger;
  // ตัวต่อกับ db prisma
  private client: PrismaClient;

  constructor(client: PrismaClient, logger: InhLogger) {
    this.client = client;
    this.logger = logger;
  }

  async getAnimalType(input: GetAnimalTypeInput): Promise<Result<GetAnimalTypeOutput>> {
    try {
      const page = input.page ? input.page : 1;
      const size = input.size ? input.size : 15;
      const skip = (page - 1) * size;
      this.logger.info({ message: skip });

      const raw = await this.client.mAS_GENERAL_DESC.findMany({
        take: size,
        skip: skip,
        where: {
          MAS_GENERAL_TYPE: {
            GDTYPE: 'ANITY',
          },
          SPTYPE: input.speciesCode,
          AND: {
            OR: [
              {
                GDCODE: {
                  // like
                  contains: input.search,
                  mode: 'insensitive',
                },
              },
              {
                LOCAL_DESCRIPTION: {
                  contains: input.search,
                  mode: 'insensitive',
                },
              },
              {
                ENGLISH_DESCRIPTION: {
                  contains: input.search,
                  mode: 'insensitive',
                },
              },
            ],
          },
        },
      });
      console.log('raw', raw);
      // map ค่า db เข้าตัวแปล
      const mapRaw: Items[] = raw.map((items) => {
        return {
          id: items.ID,
          animalTypeCode: items.GDCODE as string,
          animalTypeName: items.LOCAL_DESCRIPTION as string,
        };
      });

      const countRaw = await this.client.mAS_GENERAL_DESC.count({
        where: {
          MAS_GENERAL_TYPE: {
            GDTYPE: 'ANITY',
          },
          SPTYPE: input.speciesCode,
          AND: {
            OR: [
              {
                GDCODE: {
                  // like
                  contains: input.search,
                  mode: 'insensitive',
                },
              },
              {
                LOCAL_DESCRIPTION: {
                  contains: input.search,
                  mode: 'insensitive',
                },
              },
              {
                ENGLISH_DESCRIPTION: {
                  contains: input.search,
                  mode: 'insensitive',
                },
              },
            ],
          },
        },
      });

      const result: GetAnimalTypeOutput = {
        items: mapRaw,
        total: countRaw,
      };
      return Result.ok(result);
    } catch (error) {
      return Result.fail(error);
    }
  }
}
