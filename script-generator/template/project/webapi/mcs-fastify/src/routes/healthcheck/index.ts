import { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
// import { PrismaClient, getPrismaInstance } from '@feedos-example-system/exm-data-store-prisma';

export async function healthCheckRoute(fastify: FastifyInstance):Promise<void> {
    fastify.get('/', async (_request: FastifyRequest, reply: FastifyReply) => {
        // const prismaClient: PrismaClient = getPrismaInstance();
        try {
            // await prismaClient.$queryRaw`SELECT 1`;
            reply.status(200).send({ status: 'ok', message: 'Database avalible' });
        } catch (error) {
            fastify.log.error(error)
            reply.status(500).send({ status: 'error', message: 'Database connection failed' });
        }
    });
}
export default healthCheckRoute;