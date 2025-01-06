import {
  CreateBibleInput,
  CreateBibleOutput,
  // GetAllAnimalTypeInput,
  // GetAllAnimalTypeOutput,
  Repository,
} from '@gu-example-system/exm-api-core/command/create-bible';
import { InhLogger, Result } from '@inh-lib/common';
import { PrismaClient } from '@exm-data-store-prisma/dbclient';
import { Prisma as ExmPrisma } from '@prisma/exm-data-client';

// Function สำหรับจัดการ Prisma query แต่ละอัน
async function prismaExecute<T>(
  executtor: () => Promise<T>
): Promise<Result<T>> {
  try {
    const data = await executtor();
    return Result.ok(data)
  } catch (error) {
    return Result.fail(error)
    // return { success: false, error: error as Error };
  }
}

// สำหรับต่อ database
export class CreateBibleRepo implements Repository {
  private logger: InhLogger;
  private client: PrismaClient;


  constructor(client: PrismaClient, logger: InhLogger) {
    this.client = client;
    this.logger = logger;
  }

  async createBible(props: CreateBibleInput): Promise<Result<CreateBibleOutput>> {
    type BibleCreateRes = ExmPrisma.PromiseReturnType<typeof this.client.bIBLE.create>

// create Bible
    const bibleCreateOrFail = await prismaExecute(() => {
      return this.client.bIBLE.create({
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
    })
    if (bibleCreateOrFail.isFailure) {
      this.logger.error("CreateBibleRepo: Bible Create fail")
      return Result.fail(bibleCreateOrFail.error); // ส่ง error กลับไปเลย
    }
    const raw=bibleCreateOrFail.getValue() as BibleCreateRes;

    for (const i of props.items) {
      // find Medecine
      const findMedOrFail = await prismaExecute(() => {
        return this.client.mAS_MEDICINE.findUnique({
          where: {
            ID: i,
            AND: {
              STATUS: 'ACTIVE',
            },
          },
          select: { MEDICINE_GROUP: true, MEDICINE_TYPE_CODE: true, MEDICINE_CODE: true },
        });

      })
      if (findMedOrFail.isFailure) {
        this.logger.error("CreateBibleRepo: mAS_MEDICINE.findUnique fail")
        return Result.fail(findMedOrFail.error); // ส่ง error กลับไปเลย
      }
      const medDetail = findMedOrFail.getValue()


      // Create Bilbel Detail
      type BibleDetailCreateRes = ExmPrisma.PromiseReturnType<typeof this.client.bIBLE_DETAIL.create>
      const bibleDtlCreateOrFail = await prismaExecute(() => {
        return this.client.bIBLE_DETAIL.create({
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
        })
      })
      if (bibleDtlCreateOrFail.isFailure) {
        this.logger.error("CreateBibleRepo: bIBLE_DETAIL.create fail")
        return Result.fail(bibleDtlCreateOrFail.error); // ส่ง error กลับไปเลย
      }
      const rawDetail = bibleDtlCreateOrFail.getValue() as BibleDetailCreateRes


      // create bIBLE_DETAIL_MAPPING_MAS_MEDICINE
      const bibleDtlMasMedCreateOrFail = await prismaExecute(
        () => {
          return this.client.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.create({
            data: {
              BIBLE_DETAIL_ID: rawDetail.ID,
              MAS_MEDICINE_ID: i,
              CREATE_AT: new Date(),
              CREATE_BY: props.createBy,
            },
          })
        }
      );
      if (bibleDtlMasMedCreateOrFail.isFailure) {
        this.logger.error("CreateBibleRepo: bIBLE_DETAIL_MAPPING_MAS_MEDICINE.create fail")
        return Result.fail(bibleDtlMasMedCreateOrFail.error); // ส่ง error กลับไปเลย
      }
    }

    for (const i of props.animalType as { animalTypeCode: string; animalTypeName: string }[]) {
      // for (const i of props.animalType as string[]) {
      const bibleAnimalTypeCreateOrFail = await prismaExecute(()=>{
        return this.client.bIBLE_ANIMAL_TYPE.create({
          data: {
            BIBLE_ID: raw.ID,
            ANIMAL_TYPE_CODE: i.animalTypeCode,
            ANIMAL_TYPE_NAME: i.animalTypeName,
            CREATE_AT: new Date(),
            CREATE_BY: props.createBy,
          },
        });
      })
      if (bibleAnimalTypeCreateOrFail.isFailure) {
        this.logger.error("CreateBibleRepo: bIBLE_ANIMAL_TYPE.create fail")
        return Result.fail(bibleAnimalTypeCreateOrFail.error); // ส่ง error กลับไปเลย
      }
      const rawAnimalTypeDetail = bibleAnimalTypeCreateOrFail.getValue()
      this.logger.debug(`rawAnimalTypeDetail: ${rawAnimalTypeDetail}`);
    }

    const result: CreateBibleOutput = {
      id: raw.ID,
    };
    return Result.ok(result);
  }
}
