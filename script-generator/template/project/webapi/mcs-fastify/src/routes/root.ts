import { FastifyPluginAsync } from 'fastify'

const root: FastifyPluginAsync = async (fastify): Promise<void> => {
  fastify.get('/', async function () {
    return { root: true, message: 'Welcome to the GU MINE Web API ' }
  })
}

export default root;
