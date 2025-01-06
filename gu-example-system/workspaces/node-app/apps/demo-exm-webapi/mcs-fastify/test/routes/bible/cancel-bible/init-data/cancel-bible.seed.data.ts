import { PrismaClient } from '@prisma/exm-data-client';

export async function seedData(prisma: PrismaClient):Promise<void> {
    await prisma.$transaction([
        prisma.bIBLE.upsert({
            where: {
                ID: 'test-bible-1'
            }, create: {
                ID: 'test-bible-1',
                BIBLE_STATUS: 'CANCEL',
                STATUS: 'ACTIVE',
                CANCEL_REASON: 'cancel',
                YEAR: 2024,
                SPECIES_CODE: 'test-spiecies',
                SPECIES_NAME: 'test-spiecies-name',
                COUNTRY_CODE: 'TH',
                COUNTRY_NAME: 'thailand',
                MEDICINE_TYPE_CODE: 'test-medType-code',
                MEDICINE_TYPE_NAME: 'test-medType-name'
            },
            update: {
                ID: 'test-bible-1',
                BIBLE_STATUS: 'CANCEL',
                STATUS: 'ACTIVE',

                YEAR: 2024,
                SPECIES_CODE: 'test-spiecies',
                CANCEL_REASON: 'cancel',

                SPECIES_NAME: 'test-spiecies-name',
                COUNTRY_CODE: 'TH',
                COUNTRY_NAME: 'thailand',
                MEDICINE_TYPE_CODE: 'test-medType-code',
                MEDICINE_TYPE_NAME: 'test-medType-name'
            }
        }),
        prisma.bIBLE.upsert({
            where: {
                ID: 'test-bible-2'
            }, create: {
                ID: 'test-bible-2',
                BIBLE_STATUS: 'PUBLISHED',
                STATUS: 'ACTIVE',
                CANCEL_REASON: 'cancel',
                YEAR: 2024,
                SPECIES_CODE: 'test-spiecies',
                SPECIES_NAME: 'test-spiecies-name',
                COUNTRY_CODE: 'TH',
                COUNTRY_NAME: 'thailand',
                MEDICINE_TYPE_CODE: 'test-medType-code',
                MEDICINE_TYPE_NAME: 'test-medType-name'
            },
            update: {
                ID: 'test-bible-2',
                BIBLE_STATUS: 'PUBLISHED',
                STATUS: 'ACTIVE',

                YEAR: 2024,
                SPECIES_CODE: 'test-spiecies',
                CANCEL_REASON: 'cancel',

                SPECIES_NAME: 'test-spiecies-name',
                COUNTRY_CODE: 'TH',
                COUNTRY_NAME: 'thailand',
                MEDICINE_TYPE_CODE: 'test-medType-code',
                MEDICINE_TYPE_NAME: 'test-medType-name'
            }
        }),
        // prisma.bIBLE_DETAIL.upsert({
        //     where: {
        //         ID: 'test-bible-1'
        //     }, create: {
        //         ID: 'test-bible-1',
        //         SPECIES_CODE: 'test-spiecies',
        //         STATUS: 'INACTIVE',
        //         COUNTRY_CODE: 'TH',
        //         BIBLE_ID: 'test-bible-1'
        //     },
        //     update: {
        //         ID: 'test-bible-1',
        //         STATUS: 'INACTIVE',
        //         SPECIES_CODE: 'test-spiecies',
        //         COUNTRY_CODE: 'TH',
        //         BIBLE_ID: 'test-bible-1'

        //     }
        // }),

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

        prisma.bIBLE.deleteMany({
            where: {
                STATUS: {
                    in: ['ACTIVE']
                }
            }
        }),

        // prisma.bIBLE_DETAIL_MAPPING_MAS_MEDICINE.deleteMany({
        //     where: {
        //         MAS_MEDICINE_ID: {
        //             in: ['test-bible-med']
        //         }
        //     }
        // }),
        // prisma.mAS_MEDICINE.deleteMany({
        //     where: {
        //         ID: {
        //             in: ['test-bible-med']
        //         }
        //     }
        // }),
        // prisma.bIBLE_DETAIL.deleteMany({
        //     where: {
        //         STATUS: {
        //             in: ['ACTIVE']
        //         }
        //     }
        // }),
        // prisma.bIBLE.deleteMany({
        //     where: {
        //         STATUS: {
        //             in: ['ACTIVE']
        //         }
        //     }
        // }),
    ]);
}

