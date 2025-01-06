
import {
  Items,
  GetBibleDetailOfBibleOutPut,
  GetBibleDetailOfBibleInput,
  GetDetailBibleOutput,
  GetDetailBibleInput,
  Repository,
  Failures,
} from '@gu-example-system/exm-api-core/query/view-bible-detail';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@exm-data-store-prisma/dbclient';


export class GetBibleDetailRepo implements Repository {
  private logger: InhLogger;
  private client: PrismaClient;

  constructor(client: PrismaClient, logger: InhLogger) {
    this.client = client;
    this.logger = logger;
  }

  async getBibleDetailOfItems(props: GetBibleDetailOfBibleInput): Promise<Result<GetBibleDetailOfBibleOutPut>> {
    try {
      const page = props.page ? props.page : 1;
      const size = props.size ? props.size : 15;
      const skip = (page - 1) * size;

      const raw1 = await this.client.bIBLE_DETAIL.findMany({
        skip: skip,
        take: size,
        where: {
          BIBLE_ID: props.id,
          MEDICINE_CODE: {
            contains: props.search ? props.search : undefined,
            mode: 'insensitive',
          },
        },
        select: {
          ID: true,
          STATUS: true,
          BIBLE_DETAIL_MAPPING_MAS_MEDICINE: {
            select: {
              MAS_MEDICINE: {
                select: {
                  MEDICINE_NAME_LOCAL: true,

                  STOP_MEDICATION: true,
                  STOP_UNIT: true,
                  MEDICINE_CODE: true,
                  // MEDICINE_GROUP_NAME: true,
                  MEDICINE_GROUP: true,
                  ID: true,
                  MAS_MAPPING_MEDICINE_INGREDIENT: {
                    select: {
                      MAS_INGREDIENT: true,
                      QUANTITY: true,
                    },
                  },
                },
              },
            },
          },
        },
      });

      console.log('raw1', JSON.stringify(raw1, null, 4));
      const countRaw = await this.client.bIBLE_DETAIL.count({
        where: {
          BIBLE_ID: props.id,
          MEDICINE_CODE: {
            contains: props.search ? props.search : undefined,
            mode: 'insensitive',
          },
        },
      });

      const medGroup = raw1.flatMap((items) =>
        items.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.map((raw) => raw.MAS_MEDICINE.MEDICINE_GROUP),
      );
      const findMedGruopName = await this.client.mAS_GENERAL_DESC.findMany({
        where: {
          GDCODE: { in: medGroup as string[] },
        },
      });
      const findGdcode = findMedGruopName.map((items) => items);
      const mapRaw:Items[]  = raw1.map((items) => {
        const t = items.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.map((raw) => raw.MAS_MEDICINE.MEDICINE_GROUP).join(',');
        const filteredItems = findGdcode.find((raw) => raw.GDCODE === t);

      const res =  {
          id: items.ID,
          status: items.STATUS as string,
          // medGroupName: findMedGruopName,
          // medGroup: 'Antibionic',
          medGroup: filteredItems?.LOCAL_DESCRIPTION as string,
          // medGroup: items.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.map((raw) => raw.MAS_MEDICINE.MEDICINE_GROUP).join(','),
          medCode: items.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.map((raw) => raw.MAS_MEDICINE.MEDICINE_CODE).join(','),
          medId: items.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.map((raw) => raw.MAS_MEDICINE.ID).join(','),
          ingredient: items.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.flatMap((raw) =>
            raw.MAS_MEDICINE.MAS_MAPPING_MEDICINE_INGREDIENT.map((raw2) => {
              return {
                activeIngredient: raw2.MAS_INGREDIENT.INGREDIENT_NAME as string,
                qty: raw2.QUANTITY,
              };
            }),
          ),
          // stopPeriodUnit ไม่มีใน Type Items แล้ว จะเอา ค่า stopPeriodUnit กลับไปให้ Service ทำไม???
          stopPeriodUnit: items.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.map((raw) => raw.MAS_MEDICINE.STOP_UNIT).join(','),
          stopPeriod: items.BIBLE_DETAIL_MAPPING_MAS_MEDICINE.map((raw) => raw.MAS_MEDICINE.STOP_MEDICATION).join(','),
        } as Items;
        return res
      }) ;

      const result: GetBibleDetailOfBibleOutPut = {
        items: mapRaw,
        total: countRaw,
      };

      return Result.ok(result);
    } catch (error) {
      this.logger.error({ message: `error in repo getCountry => ${error} ` });
      return Result.fail(error);
    }
  }

  async getDetailBible(props: GetDetailBibleInput): Promise<Result<GetDetailBibleOutput>> {
    try {
      const raw = await this.client.bIBLE.findUnique({
        where: {
          ID: props.id,
        },
        include: {
          BIBLE_ANIMAL_TYPE: true,
        },
      });
      // console.log('raw', raw);
      if (!raw) {
        return Result.fail(new Failures.GetFail());
      }
      const result: GetDetailBibleOutput = {
        id: raw.ID,
        cancelRemark: raw.CANCEL_REASON as string,
        animalType: raw.BIBLE_ANIMAL_TYPE.map((items) => {
          return {
            animalTypeCode: items.ANIMAL_TYPE_CODE as string ,
            animalTypeName: items.ANIMAL_TYPE_NAME as string,
          };
        }),
        country: {
          countryCode: raw.COUNTRY_CODE as string,
          countryName: raw.COUNTRY_NAME as string,
        },
        medType: {
          medTypeCode: raw.MEDICINE_TYPE_CODE as string,
          medTypeName: raw.MEDICINE_TYPE_NAME as string,
        },
        createAt: raw.CREATE_AT as Date,
        createBy: raw.CREATE_BY as string,
        remarks: raw.REMARKS as string,
        species: {
          speciesCode: raw.SPECIES_CODE,
          speciesName: raw.SPECIES_NAME as string,
        },
        status: raw.BIBLE_STATUS,
        updateAt: raw.UPDATE_AT as Date,
        updateBy: raw.UPDATE_BY as string,
        year: raw.YEAR,
      };
      return Result.ok(result);
    } catch (error) {
      this.logger.error({ message: `error in repo getCountry => ${error} ` });
      return Result.fail(error);
    }
  }
}
