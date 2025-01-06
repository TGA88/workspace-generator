import { PrismaClient } from '@prisma/exm-data-client';
const UserRole= {Admin:"admin"}

export async function getPermissionAndRoleSeed(prisma: PrismaClient):Promise<void> {
    await prisma.$transaction([
        prisma.mAS_COUNTRY.upsert({
            where: {
                ID: '21392098230009857'
            }, create: {
                ID: '21392098230009857',
                COUNTRY_CODE: 'TH',
                COUNTRY_NAME: 'Thailand',
            }, update: {
                COUNTRY_CODE: 'TH',
                COUNTRY_NAME: 'Thailand',
            }
        }),
        prisma.mAS_GENERAL_TYPE.upsert({
            where: {
                ID: 'SPTYP'
            }, create: {
                ID: 'SPTYP',
                GDTYPE: 'SPTYP',
                TYPE_DESCRIPTION: 'Species Type',
                STATUS: 'ACTIVE'
            }, update: {
                GDTYPE: 'SPTYP',
                TYPE_DESCRIPTION: 'Species Type',
                STATUS: 'ACTIVE'
            }
        }),
        prisma.mAS_GENERAL_DESC.upsert({
            where: {
                ID: "SCRIPT075"
            }, create: {
                ID: "SCRIPT075",
                GDCODE: 'SPTYP_SW',
                MAS_GENERAL_TYPE_ID: 'SPTYP',
                LOCAL_DESCRIPTION: 'Swine',
                ENGLISH_DESCRIPTION: 'Swine',
                STATUS: 'ACTIVE'
            }, update: {
                GDCODE: 'SPTYP_SW',
                MAS_GENERAL_TYPE_ID: 'SPTYP',
                LOCAL_DESCRIPTION: 'Swine',
                ENGLISH_DESCRIPTION: 'Swine',
                STATUS: 'ACTIVE'
            }
        }),
        prisma.aCCOUNT_MAS_COUNTRY.upsert({
            where: {
                ID: 'test-account-mas-country-1'
            }, create: {
                ID: 'test-account-mas-country-1',
                ACCOUNT_ID: 'test-account-1',
                MAS_COUNTRY_ID: '21392098230009857',
                COUNTRY_CODE: 'TH'
            }, update: {
                ACCOUNT_ID: 'test-account-1',
                MAS_COUNTRY_ID: '21392098230009857',
                COUNTRY_CODE: 'TH'
            }
        }),
        prisma.aCCOUNT_MAS_SPECIES.upsert({
            where: {
                ID: 'test-account-mas-species-1'
            }, create: {
                ID: 'test-account-mas-species-1',
                ACCOUNT_ID: 'test-account-1',
                SPECIES_CODE: 'SPTYP_SW',
            }, update: {
                ACCOUNT_ID: 'test-account-1',
                SPECIES_CODE: 'SPTYP_SW',
            }
        }),
        prisma.aCCOUNT_ORG.upsert({
            where: {
                ID: 'test-account-org-1'
            }, create: {
                ID: 'test-account-org-1',
                ACCOUNT_ID: 'test-account-1',
                ORG_CODE: '300110',
                ORG_NAME: 'บมจ.funny(ประเทศไทย)-ท่าเรือ'
            }, update: {
                ACCOUNT_ID: 'test-account-1',
                ORG_CODE: '300110',
                ORG_NAME: 'บมจ.funny(ประเทศไทย)-ท่าเรือ'
            }
        }),
        prisma.aCCOUNT_ROLE.upsert({
            where: {
                ID: 'test-account-role-1'
            }, create: {
                ID: 'test-account-role-1',
                ACCOUNT_ID: 'test-account-1',
                ROLE_CODE: UserRole.Admin,
                ROLE_NAME: UserRole.Admin
            }, update: {
                ACCOUNT_ID: 'test-account-1',
                ROLE_CODE: UserRole.Admin,
                ROLE_NAME: UserRole.Admin
            }
        }),

    ]);
}

export async function getPermissionAndRoleClear(prisma: PrismaClient):Promise<void> {
    await prisma.$transaction([
        prisma.aCCOUNT_ROLE.deleteMany({
            where: {
                ID: {
                    in: ['test-account-role-1']
                }
            }
        }),
        prisma.aCCOUNT_ORG.deleteMany({
            where: {
                ID: {
                    in: ['test-account-org-1']
                }
            }
        }),
        prisma.aCCOUNT_MAS_SPECIES.deleteMany({
            where: {
                ID: {
                    in: ['test-account-mas-species-1']
                }
            }
        }),
        prisma.aCCOUNT_MAS_COUNTRY.deleteMany({
            where: {
                ID: {
                    in: ['test-account-mas-country-1']
                }
            }
        }),
        // prisma.mAS_GENERAL_DESC.deleteMany({
        //     where: {
        //         ID: {
        //             in: ['SCRIPT075']
        //         }
        //     }
        // }),
        // prisma.mAS_GENERAL_TYPE.deleteMany({
        //     where: {
        //         ID: {
        //             in: ['SPTYP']
        //         }
        //     }
        // }),
        // prisma.mAS_COUNTRY.deleteMany({
        //     where: {
        //         ID: {
        //             in: ['21392098230009857']
        //         }
        //     }
        // }),
    ]);
}