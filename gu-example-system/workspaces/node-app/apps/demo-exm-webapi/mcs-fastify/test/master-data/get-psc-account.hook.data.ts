import { PrismaClient } from '@prisma/exm-data-client';

export async function mineAccountSeed(prisma: PrismaClient):Promise<void> {
    await prisma.$transaction([
        prisma.vETERINARIAN.upsert({
            where: {
                ID: 'test-veterinarian-1'
            }, create: {
                ID: 'test-veterinarian-1',
                STATUS: 'ACTIVE',
                EMAIL: 'veterinarian@email.com',
                FIRST_NAME_LOCAL: 'first_name_local',
                FIRST_NAME_ENG: 'first_name_eng',
                LAST_NAME_LOCAL: 'last_name_local',
                LAST_NAME_ENG: 'last_name_eng',
                NAME_LOCAL: 'name_local',
                NAME_ENG: 'name_eng',
                TITLE_CODE: 'title_code',
                FARM_LICENSE: 'farm_license',
                FARM_LICENSE_CK: 'farm_license_ck',
                PROFESSIONAL_LICENSE: 'professional_license',
                VETERINARIAN_CODE: 'veterinarian_code',
                VETERINARIAN_ID: 1,
            }, update: {
                ID: 'test-veterinarian-1',
                STATUS: 'ACTIVE',
                EMAIL: 'veterinarian@email.com',
                FIRST_NAME_LOCAL: 'first_name_local',
                FIRST_NAME_ENG: 'first_name_eng',
                LAST_NAME_LOCAL: 'last_name_local',
                LAST_NAME_ENG: 'last_name_eng',
                NAME_LOCAL: 'name_local',
                NAME_ENG: 'name_eng',
                TITLE_CODE: 'title_code',
                FARM_LICENSE: 'farm_license',
                FARM_LICENSE_CK: 'farm_license_ck',
                PROFESSIONAL_LICENSE: 'professional_license',
                VETERINARIAN_CODE: 'veterinarian_code',
                VETERINARIAN_ID: 1,
            }
        }),
        prisma.aCCOUNT.upsert({
            where: {
                ID: 'test-account-1'
            }, create: {
                ID: 'test-account-1',
                EMAIL: 'intregretion@email.com',
                USERNAME: 'test_account_username',
                STATUS: 'ACTIVE',
                LOCAL_LANGUAGE: "EN",
                VETERINARIAN_ID: 'test-veterinarian-1',
                IDENTIFY_ID: 'id-from-gu-portal-mas-user',
                USERNAME_PORTAL: 'username-from-gu-portal-mas-user',
                ONBOARDING_MATCHING_EMAIL: false,
                ONBOARDING_USER_1: false,
                ONBOARDING_USER_2: false,
                ONBOARDING_VETERINARIAN: false
            }, update: {
                ID: 'test-account-1',
                EMAIL: 'intregretion@email.com',
                USERNAME: 'test_account_username',
                STATUS: 'ACTIVE',
                LOCAL_LANGUAGE: "EN",
                VETERINARIAN_ID: 'test-veterinarian-1',
                IDENTIFY_ID: 'id-from-gu-portal-mas-user',
                USERNAME_PORTAL: 'username-from-gu-portal-mas-user',
                ONBOARDING_MATCHING_EMAIL: false,
                ONBOARDING_USER_1: false,
                ONBOARDING_USER_2: false,
                ONBOARDING_VETERINARIAN: false
            }
        }),
    ]);
}

export async function mineAccountClearData(prisma: PrismaClient):Promise<void> {
    await prisma.$transaction([
        prisma.aCCOUNT.deleteMany({
            where: {
                ID: {
                    in: ['1']
                }
            }
        }),
        prisma.vETERINARIAN.deleteMany({
            where: {
                ID: {
                    in: ['test-veterinarian-1']
                }
            }
        }),
        prisma.aCCOUNT.deleteMany({
            where: {
                ID: {
                    in: ['test-account-1']
                }
            }
        })
    ]);
}