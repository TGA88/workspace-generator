import { FastifyInstance, preValidationHookHandler } from "fastify";
import { PrismaClient, getPrismaInstance } from '@gu-example-system/exm-data-store-prisma'

/**
 * must use after get-psc-account
 * @param fastify 
 * @returns 
 */
export function getPermissionAndRole(fastify: FastifyInstance): preValidationHookHandler {
    fastify.addHook('preHandler', async (req, reply) => {
        try {
            fastify.log.debug({ message: `req['veterinarianId'], ${req['veterinarianId']}` })
            const prismaClient: PrismaClient = getPrismaInstance();
            let countryCode: string[], speciesCode: string[]
            //get mas_country_farm if has data then get country and species depend on 
            const accountMasCountryFarm = await prismaClient.aCCOUNT_MAS_COUNTRY_FARM.findMany({
                where: {
                    // ACCOUNT: {
                    //     VETERINARIAN: {
                    //         ID: req['veterinarianId']
                    //     }
                    // },
                    ACCOUNT: {
                        ID: req['accountId']
                    }
                }, select: {
                    MAS_COUNTRY_FARM: {
                        select: {
                            CV_CODE: true
                        }
                    }
                }
            })
          prismaClient.aCCOUNT_MAS_COUNTRY_FARM
            
            const mapCVCode = accountMasCountryFarm.map((data: { MAS_COUNTRY_FARM: { CV_CODE: string; }; } ) => data.MAS_COUNTRY_FARM.CV_CODE as string)
            if (mapCVCode.length > 0) {
                console.log('case: set MAS_COUNTRY_FARM')
                const groupCountryCode = await prismaClient.mAS_COUNTRY_FARM.groupBy({
                    where: {
                        CV_CODE: {
                            in: mapCVCode
                        }
                    }, by: ['COUNTRY_CODE']
                })
                countryCode = groupCountryCode.map((data: { COUNTRY_CODE: string; }) => data.COUNTRY_CODE as string)

                const groupSpeciesCode = await prismaClient.mAS_COUNTRY_FARM.groupBy({
                    where: {
                        CV_CODE: {
                            in: mapCVCode
                        }
                    }, by: ['SPECIES_CODE']
                })

                speciesCode = groupSpeciesCode.map((data: { SPECIES_CODE: string; }) => data.SPECIES_CODE as string)
            }
            else {
                console.log('case: set not set MAS_COUNTRY_FARM')
                const accountMasCountry = await prismaClient.aCCOUNT_MAS_COUNTRY.findMany({
                    where: {
                        // ACCOUNT: {
                        //     VETERINARIAN: {
                        //         ID: req['veterinarianId']
                        //     }
                        // },
                        ACCOUNT: {
                            ID: req['accountId']
                        }
                    }, select: {
                        MAS_COUNTRY: {
                            select: {
                                COUNTRY_CODE: true
                            }
                        }
                    }
                })
                countryCode = accountMasCountry.map((data: { MAS_COUNTRY: { COUNTRY_CODE: string; }; }) => data.MAS_COUNTRY.COUNTRY_CODE)

                const accountMasSpecies = await prismaClient.aCCOUNT_MAS_SPECIES.findMany({
                    where: {
                        // ACCOUNT: {
                        //     VETERINARIAN: {
                        //         ID: req['veterinarianId']
                        //     }
                        // },
                        ACCOUNT: {
                            ID: req['accountId']
                        }
                    }, select: {
                        SPECIES_CODE: true
                    }
                })
                speciesCode = accountMasSpecies.map((data: { SPECIES_CODE: string }) => data.SPECIES_CODE)
            }



            const accountOrg = await prismaClient.aCCOUNT_ORG.findMany({
                where: {
                    // ACCOUNT: {
                    //     VETERINARIAN: {
                    //         ID: req['veterinarianId']
                    //     }
                    // },
                    ACCOUNT: {
                        ID: req['accountId']
                    }
                }, select: {
                    ORG_CODE: true
                }
            })

            const accountBu = await prismaClient.aCCOUNT_BU.findMany({
                where: {
                    // ACCOUNT: {
                    //     VETERINARIAN: {
                    //         ID: req['veterinarianId']
                    //     }
                    // },
                    ACCOUNT: {
                        ID: req['accountId']
                    }
                }, select: {
                    BU_CODE: true
                }
            })

            const accountRole = await prismaClient.aCCOUNT_ROLE.findMany({
                where: {
                    // ACCOUNT: {
                    //     VETERINARIAN: {
                    //         ID: req['veterinarianId']
                    //     }
                    // },
                    ACCOUNT: {
                        ID: req['accountId']
                    }
                }, select: {
                    ROLE_CODE: true
                }
            })

            req['userPermission'] = req['userPermission'] || {};

            req.userPermission.countryCode = countryCode
            req.userPermission.speciesCode = speciesCode
            req.userPermission.cvCode = mapCVCode
            req.userPermission.orgCode = accountOrg.map((data: { ORG_CODE: string }) => data.ORG_CODE)
            req.userPermission.buCode = accountBu.map((data: { BU_CODE: string }) => data.BU_CODE)
            req.userRole = accountRole.map((data: { ROLE_CODE: string }) => data.ROLE_CODE)
        } catch (error) {
            req.log.error(`error in getPermissionAndRole: ${error}`)
            reply.status(401).send({ success: false, message: `error in middleware getPermissionAndRole` })
        }
    })
    return (_req, _reply, done) => {
        done();
    };
}
