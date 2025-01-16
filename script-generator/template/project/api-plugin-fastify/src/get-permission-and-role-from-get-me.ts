import axios from "axios";
import { FastifyInstance, preValidationHookHandler } from "fastify";


interface Headers {
    authorization: string,
    byPassUserId: string,
    byPassUid: string
    loginType: string
}

/**
 * middleware for get userPermission and role outside of FOS-PSC-WEBAPI
 * @param fastify 
 * @returns 
 */
export function getPermissionAndRoleFromGetMe(fastify: FastifyInstance): preValidationHookHandler {
    fastify.addHook('preHandler', async (req, reply) => {
        try {
            // const accessToken = getToken(req.headers.authorization as string)
            // const loginType = req.headers['login-type'] as string
            const getMeApi = await getMePscWebapi({
                authorization: req.headers.authorization as string,
                loginType: req.headers['login-type'] as string,
                byPassUid: req.headers['by-pass-uid'] as string,
                byPassUserId: req.headers['by-pass-userid'] as string
            })

            req['userPermission'] = getMeApi.userPermission
            req['userRole'] = getMeApi.userRole

            fastify.log.info({ userPermission: `${JSON.stringify(req['userPermission'], null, 4)}` })
        } catch (error) {
            req.log.error(`error in getPermissionAndRoleFromGetMe: ${error}`)
            reply.status(401).send({ success: false, message: `Unauthorize step getPermissionAndRoleFromGetMe: ${error}` })
        }
    })
    return (_req, _reply, done) => {
        done();
    };
}

type GetMeResult = {
    userProfile: {
        veterinarianId: string
        email: string,
        firstNameLocal: string,
        firstNameEng: string,
        lastNameLocal: string,
        lastNameEng: string,
        nameLocal: string,
        nameEng: string,
        titleCode: string,
        farmLicense: string,
        farmLicenseCK: string,
        professionalLicense: string,
        veterinarianCode: string,
    },
    userPermission: {
        countryCode: string[]
        speciesCode: string[]
        cvCode: string[]
        buCode: string[]
        orgCode: string[]
        farmCode: string[]
    }
    userRole: string[]
}
async function getMePscWebapi(headers: Headers): Promise<GetMeResult> {
    console.log('headers', headers)
    const url = process.env.FOS_PSC_WEBAPI_URL
    const fetch = await axios
        .get(
            `${url}/prescription/get-me`,
            {
                headers: {
                    "Authorization": headers.authorization ? `${headers.authorization}` : undefined,
                    "Login-Type": headers.loginType ? headers.loginType : undefined,
                    "By-Pass-Userid": headers.byPassUserId ? headers.byPassUserId : undefined,
                    "By-Pass-Uid": headers.byPassUid ? headers.byPassUid : undefined
                }
            },
        )
        .then((res) => {
            return res.data.data
        })
        .catch((error) => {
            console.log('error', JSON.stringify(error, null, 4))
            throw new Error(`error in getMePscWebapi: ${error}`)
        });
    const result: GetMeResult = {
        ...fetch
    }
    return result
}