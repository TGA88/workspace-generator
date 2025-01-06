import fastify, { FastifyRequest } from 'fastify';
import app from './app';
// import { UniqueEntityID } from '@inh-lib/ddd';
// import { FastifyCustomHookRequest } from '@api-utils/fastify-custom-hook'

declare module 'fastify' {
  interface FastifyInstance {
    jwtAuth: (fastify: FastifyInstance) => void;
  }
  // interface FastifyRequest extends FastifyCustomHookRequest {
  //   traceId: string
  // }
}

declare module 'http' {
  interface IncomingMessage {
    files: {
      [key: string]: {
        name: string;
        data: Buffer;
        size: number;
        encoding: string;
        tempFilePath: string;
        truncated: boolean;
        mimetype: string;
        md5: string;
        mv: () => void;
      };
    };
  }
}

const host = process.env.HOST ?? 'localhost';
const port = process.env.PORT ? Number(process.env.PORT) : 3001;

const fastifyApp = fastify({
  logger: {
    level: process.env.APP_LOG_LEVEL ?? 'debug',
    timestamp: () => `,"time":"${new Date().toISOString()}"`,
  },
});

fastifyApp.addHook('preHandler', (request: FastifyRequest, reply, done) => {
  // request.traceId = new UniqueEntityID().toString();
  // console.log('req', request.traceId)
  done();
});


const start = async ():Promise<void> => {
  try {
    fastifyApp.register(app);
    console.log(`[ ready ]  http://${host}:${port}`);
    console.log(`[check] , ${process.env.HOST}`);
    console.log(`[check] , ${process.env.AWS_ENDPOINT}`);
  } catch (err) {
    console.log('error', err)
    process.exit(1);
  }
};

start();
