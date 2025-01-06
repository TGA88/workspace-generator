import fp from 'fastify-plugin'

import FastifyLogAdapter from '../utils/fastify-log-adapter'
import { InhLogger } from '@inh-lib/common'

export interface FastifyInhLogAdapterPluginOptions {
  // Specify Support plugin options here
}

// The use of fastify-plugin is required to be able
// to export the decorators to the outer scope
export default fp<FastifyInhLogAdapterPluginOptions>(async (fastify) => {
  fastify.log.info("init inhLogger ")
  const inhLogger = new FastifyLogAdapter(fastify.log)
  fastify.decorate('inhLogger', inhLogger)
})

// When using .decorate you have to specify added properties for Typescript
declare module 'fastify' {
  export interface FastifyInstance {
    inhLogger: InhLogger;
  }
}
