import axios from "axios";
import { FastifyInstance, preValidationHookHandler } from "fastify";
import { PrismaClient, getPrismaInstance } from '@gu-example-system/exm-data-store-prisma'

interface Headers {
    authorization: string,
    byPassUserId: string,
    byPassUid: string
    loginType: string
}

interface GetListGroupResponse {
    success: boolean,
    data: {
        listGroupOrgPermission:
        {
            groupCode: string,
            groupName: string
        }[]
    }
}
interface GetRoleFromFeedPortalResponse {
    listGroupOrgPermission:
    {
        groupCode: string,
        groupName: string
    }[]
}

async function getRoleFromFeedPortalApi(headers: Headers): Promise<GetRoleFromFeedPortalResponse> {
    const url = process.env.FEED_PORTAL_API_URL
    const https = require('https');
    const agent = new https.Agent({
        rejectUnauthorized: false
    });
    try {
        const fetch = await axios.get(`${url}/gu-portal-webapi/portal-user/get-list-group`, {
            headers: {
                "Authorization": headers.authorization ? `${headers.authorization}` : undefined,
                "Login-Type": headers.loginType ? headers.loginType : undefined,
                "By-Pass-User-Id": headers.byPassUserId ? headers.byPassUserId : undefined,
                "By-Pass-Uid": headers.byPassUid ? headers.byPassUid : undefined
            },
            params: {
                system: "FEEDOS",
                moduleCode: "FEEDOSPSC"
            },
            httpAgent: agent
        },
        ).then((res: { data: GetListGroupResponse }) => {
            return res.data.data
        }).catch((error) => {
            throw new Error(`error in getRoleFromFeedPortal: ${error}`)
        });
        const result: GetRoleFromFeedPortalResponse = {
            listGroupOrgPermission: fetch.listGroupOrgPermission
        }
        return result
    } catch (error) {
        throw new Error(`error in getRoleFromFeedPortal: ${error}`)
    }
}

export function updateRoleFromFeedPortal(fastify: FastifyInstance): preValidationHookHandler {
    fastify.addHook('preValidation', async (req, reply) => {
        try {
            const prismaClient: PrismaClient = getPrismaInstance();
            const getRoleFromFeedPortal = await getRoleFromFeedPortalApi({
                authorization: req.headers.authorization as string,
                loginType: req.headers['login-type'] as string,
                byPassUid: req.headers['by-pass-uid'] as string,
                byPassUserId: req.headers['by-pass-userid'] as string
            })

            const accountRole = await prismaClient.aCCOUNT_ROLE.findMany({
                where: {
                    ACCOUNT: {
                        USERNAME: req.accountUsername
                    }
                }, select: {
                    ID: true,
                    ROLE_CODE: true,
                    ROLE_NAME: true
                }
            })

            const notUsedRole = accountRole.filter((data: { ROLE_CODE: string; }) => !getRoleFromFeedPortal.listGroupOrgPermission.some((item) => item.groupCode == data.ROLE_CODE))
            if (notUsedRole.length > 0) {
                for (const record of notUsedRole) {
                   await prismaClient.aCCOUNT_ROLE.delete({
                        where: {
                            ID: record.ID
                        }
                    })
                }
            }
            const newRole = getRoleFromFeedPortal.listGroupOrgPermission.filter(data => !accountRole.some((record: { ROLE_CODE: string; ROLE_NAME: string; }) => data.groupCode == record.ROLE_CODE && data.groupName == record.ROLE_NAME))
            if (newRole.length > 0) {
                for (const record of newRole) {
                    await prismaClient.aCCOUNT_ROLE.create({
                        data: {
                            ROLE_CODE: record.groupCode,
                            ROLE_NAME: record.groupName,
                            CREATE_BY: 'SYSTEM',
                            ACCOUNT: {
                                connect: {
                                    USERNAME: req.accountUsername
                                }
                            }
                        }
                    })
                }
            }
        } catch (error) {
            req.log.error(`error in updateRoleFromFeedPortal: ${error}`)
            reply.status(401).send({ success: false, message: `Error in process updateRoleFromFeedPortal` })
        }
    })
    return (_req, _reply, done) => {
        done();
    };
}


