import { FastifyInstance, preValidationHookHandler } from "fastify";

/**
 * must use after get-permission-and-role
 * @param fastify fastify instance
 * @param requireRole role that require for use api
 * @returns 
 */
export function checkRole(fastify: FastifyInstance, requireRole: string[]): preValidationHookHandler {
    fastify.addHook('preHandler', async (req, reply) => {
        try {
            const checkRole = req.userRole.some((ur) => requireRole.includes(ur))
            if (!checkRole) {
                throw new Error("You do not have permission to access this API. Please contact your administrator for assistance.")
            }
        } catch (error) {
            req.log.error(`error in getPermissionAndRole: ${error}`)
            reply.status(401).send({ success: false, message: `${error}` })
        }
    })
    return (_req, _reply, done) => {
        done();
    };
}