import { FastifyInstance, FastifyReply, FastifyRequest, HookHandlerDoneFunction, preValidationHookHandler } from 'fastify';
import { PrismaClient, getPrismaInstance } from '@gu-example-system/exm-data-store-prisma'
import axios from 'axios'
import { getToken } from './logics/get-token';

/**
 * use for verify token in gu-portal then get user in table ACCOUNT
 * @param fastify 
 * @returns 
 * req.veterinarianId => ID of table VETERINARIAN;
 * req.veterinarianCode => VETERINARIAN_CODE of table VETERINARIAN;
 */
export function getPscAccount(fastify: FastifyInstance): preValidationHookHandler {
    fastify.addHook('preHandler', async (req, reply) => {
        try {
            const prismaClient: PrismaClient = getPrismaInstance();
            if (process.env.DEV_MODE == 'true' && req.headers['by-pass-userid'] && req.headers['by-pass-uid']) {
                const veterinarian = await prismaClient.aCCOUNT.findUnique({
                    where: {
                        IDENTIFY_ID: req.headers['by-pass-userid'] as string,
                        STATUS: 'ACTIVE'
                    }, select: {
                        ID: true,
                        LOCAL_LANGUAGE: true,
                        USERNAME: true,
                        VETERINARIAN: true
                    }
                })
                if (!veterinarian) {
                    throw new Error('veterinarian not found or INACTIVE')
                }
                req['veterinarianId'] = veterinarian?.VETERINARIAN?.ID as string
                req['veterinarianCode'] = veterinarian?.VETERINARIAN?.VETERINARIAN_CODE as string
                req['userLanguage'] = veterinarian.LOCAL_LANGUAGE as string
                req.accountUsername = veterinarian.USERNAME
                req.accountId = veterinarian.ID
                req.veterinarianName = veterinarian.VETERINARIAN?.NAME_LOCAL as string

                console.log('req.accountUsername', req.accountUsername)
                return (_req:FastifyRequest, _reply:FastifyReply, done:HookHandlerDoneFunction):void => {
                    done();
                } 
            }

            const accessToken = getToken(req.headers.authorization as string)
            const tokenVerify = await verifyTokenFeedPortalSystem(accessToken, req.headers['login-type'])
            const veterinarian = await prismaClient.aCCOUNT.findUnique({
                where: {
                    IDENTIFY_ID: tokenVerify.id,
                    STATUS: 'ACTIVE'
                }, select: {
                    ID: true,
                    LOCAL_LANGUAGE: true,
                    USERNAME: true,
                    VETERINARIAN: true
                }
            })
            if (!veterinarian) {
                throw new Error('veterinarian not found or INACTIVE')
            }

            req['veterinarianId'] = veterinarian?.VETERINARIAN?.ID as string
            req['veterinarianCode'] = veterinarian?.VETERINARIAN?.VETERINARIAN_CODE as string
            req['userLanguage'] = veterinarian?.LOCAL_LANGUAGE as string
            req.accountUsername = veterinarian.USERNAME
            req.accountId = veterinarian.ID
            req.veterinarianName = veterinarian.VETERINARIAN?.NAME_LOCAL as string
            console.log('req.accountUsername', req.accountUsername)
        } catch (error) {
            req.log.error(`error in getPscAccount: ${error}`)
            reply.status(401).send({ success: false, message: `Unauthorize while get mine account` })
        }
    })
    return (_req, _reply, done) => {
        done();
    };
}

async function verifyTokenFeedPortalSystem(token: string, loginType: string | string[] | undefined): Promise<{ id: string, username: string, phone: string }> {
    const url = process.env.FEED_PORTAL_API_URL
    const https = require('https');
    const agent = new https.Agent({
        rejectUnauthorized: false
    });
    const fetch = await axios
        .get(
            `${url}/gu-portal-webapi/auth/token-verify`,
            {
                headers: {
                    "Login-Type": loginType,
                    "Authorization": `Bearer ${token}`,
                },
                params: {
                    accessToken: token
                },
                httpsAgent: agent
            },
        )
        .then((res) => {
            return res.data
        })
        .catch((error) => {
            console.log('error', error)
            throw new Error(`error in verifyTokenFeedPortalSystem: ${error}`)
        });

    const result = {
        id: fetch.data.id,
        username: fetch.data.username,
        phone: fetch.data.phone
    }
    return result
}