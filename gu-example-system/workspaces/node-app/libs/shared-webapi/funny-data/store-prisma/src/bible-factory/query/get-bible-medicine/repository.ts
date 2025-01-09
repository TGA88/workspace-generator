import {
  Items,
  GetMedicineInput,
  GetMedicineOutput,
  Repository,
} from '@gu-example-system/funny-api-core/query/get-bible-medicine';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@funny-data-store-prisma/dbclient';

export class GetMedicineRepo implements Repository {
  private logger: InhLogger;
  private client: PrismaClient;

  constructor(client: PrismaClient, logger: InhLogger) {
    this.client = client;
    this.logger = logger;
  }
  async getMedicine(props: GetMedicineInput): Promise<Result<GetMedicineOutput>> {
    try {
      const page = props.page ? props.page : 1;
      const size = props.size ? props.size : 15;
      const skip = (page - 1) * size;
      // console.log('input', props);
      const raw = await this.client.mAS_MEDICINE.findMany({
        skip: skip,
        take: size,
        where: {
          STATUS: 'ACTIVE',
          MEDICINE_TYPE_CODE: props.medicineTypeCode,
          COUNTRY_CODE: props.countryCode,
          AND: {
            OR: [
              {
                MEDICINE_CODE: {
                  contains: props.search as string,
                  mode: 'insensitive',
                },
              },
              {
                MEDICINE_NAME_LOCAL: {
                  contains: props.search as string,
                  mode: 'insensitive',
                },
              },
              {
                MEDICINE_NAME_ENG: {
                  contains: props.search as string,
                  mode: 'insensitive',
                },
              },
            ],
          },
          MAS_MEDICINE_SPECIES: { some: { SPECIES_CODE: props.speciesCode } },
        },
        orderBy: {
          ID: 'asc',
        },
        select: {
          ID: true,
          MEDICINE_CODE: true,
          MEDICINE_NAME_LOCAL: true,
        },
      });
      // console.log('raw2', raw2);
      const countRaw = await this.client.mAS_MEDICINE.count({
        where: {
          STATUS: 'ACTIVE',
          MEDICINE_TYPE_CODE: props.medicineTypeCode,
          COUNTRY_CODE: props.countryCode,
          AND: {
            OR: [
              {
                MEDICINE_CODE: {
                  contains: props.search as string,
                  mode: 'insensitive',
                },
              },
              {
                MEDICINE_NAME_LOCAL: {
                  contains: props.search as string,
                  mode: 'insensitive',
                },
              },
              {
                MEDICINE_NAME_ENG: {
                  contains: props.search as string,
                  mode: 'insensitive',
                },
              },
            ],
          },
          MAS_MEDICINE_SPECIES: { some: { SPECIES_CODE: props.speciesCode } },
        },
      });
      // console.log('raw', JSON.stringify(raw, null, 4))

      const mapRaw: Items[] = raw.map((data) => {
        return {
          id: data.ID,
          medCode: data.MEDICINE_CODE as string,
          medName: data.MEDICINE_NAME_LOCAL as string,
        };
      });

      const result: GetMedicineOutput = {
        items: mapRaw,
        total: countRaw,
      };

      return Result.ok(result);
    } catch (error) {
      this.logger.error({ message: `error in repo getBibleMedicine => ${error}` });
      return Result.fail(error);
    }
  }
}
