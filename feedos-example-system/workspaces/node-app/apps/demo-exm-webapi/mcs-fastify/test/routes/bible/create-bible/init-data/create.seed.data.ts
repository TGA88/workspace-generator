import { PrismaClient } from '@prisma/exm-data-client';

export async function seedData(prisma: PrismaClient):Promise<void> {
    await prisma.$transaction([
        prisma.mAS_MEDICINE.upsert({
            where: {
                ID: 'test-bible-med'
            }, create: {
                ID: 'test-bible-med',
                STATUS: 'ACTIVE',
                MEDICINE_CODE: 'med-code',
                MEDICINE_TYPE_CODE: 'med-type-code',
                COUNTRY_CODE: 'TH',
                MEDICINE_NAME_LOCAL: 'med-local',

            },
            update: {
                ID: 'test-bible-med',
                STATUS: 'ACTIVE',
                MEDICINE_CODE: 'med-code',
                MEDICINE_TYPE_CODE: 'med-type-code',
                COUNTRY_CODE: 'TH',
                MEDICINE_NAME_LOCAL: 'med-local',
            }
        }),
    ]);
}

export async function clearData(prisma: PrismaClient):Promise<void> {
    await prisma.$transaction([
        prisma.bIBLE_ANIMAL_TYPE.deleteMany({
            where: {
                ANIMAL_TYPE_CODE: {
                    in: ['test-animal-code']
                }
            }
        }),
        prisma.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.deleteMany({
            where: {
                MAS_MEDICINE_ID: {
                    in: ['test-bible-med']
                }
            }
        }),
        prisma.mAS_MEDICINE.deleteMany({
            where: {
                ID: {
                    in: ['test-bible-med']
                }
            }
        }),
        prisma.bIBLE_DETAIL.deleteMany({
            where: {
                STATUS: {
                    in: ['ACTIVE']
                }
            }
        }),
        prisma.bIBLE.deleteMany({
            where: {
                STATUS: {
                    in: ['ACTIVE']
                }
            }
        }),
    ]);
}

