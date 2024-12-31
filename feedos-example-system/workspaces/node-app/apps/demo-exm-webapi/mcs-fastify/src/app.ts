import { join } from 'path';
import AutoLoad, { AutoloadPluginOptions } from '@fastify/autoload';
import { FastifyPluginAsync, FastifyRequest, FastifyServerOptions } from 'fastify';
import { UniqueEntityID } from '@inh-lib/ddd';
import cors from '@fastify/cors'

declare module 'fastify' {
    export interface FastifyRequest {
      traceId: string | number
    }
}

export interface AppOptions
  extends FastifyServerOptions,
  Partial<AutoloadPluginOptions> { }
// Pass --options via CLI arguments in command to enable these options.
const options: AppOptions = {};

const app: FastifyPluginAsync<AppOptions> = async (
  fastify,
  opts
): Promise<void> => {
  // Place here your custom code!
  fastify.register(cors, {
    origin: '*',
  });

  fastify.addHook('preHandler', (request: FastifyRequest, reply, done) => {
    request.traceId = new UniqueEntityID().toString();
    console.log('req.traceId', request.traceId)
    done();
  });

  

  // Do not touch the following lines

  // This loads all plugins defined in plugins
  // those should be support plugins that are reused
  // through your application
  fastify.register(AutoLoad, {
    dir: join(__dirname, 'plugins'),
    options: opts,
  });

  // This loads all plugins defined in routes
  // define your routes in one of these
  fastify.register(AutoLoad, {
    dir: join(__dirname, 'routes'),
    options: opts,
    ignoreFilter: /endpoint\.ts/,
    prefix: process.env.API_PREFIX ? process.env.API_PREFIX : '/psc-webapi',
  });
};


export default app;
export { app, options };
