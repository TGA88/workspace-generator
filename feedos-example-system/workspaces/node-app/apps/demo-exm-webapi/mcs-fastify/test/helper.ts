import Fastify, { FastifyPluginAsync } from 'fastify';
import fp from 'fastify-plugin';
import snsTrnprescriptionChangedClient from '../src/plugins/sns-trnprescription-changed.client';

export function build(route: FastifyPluginAsync) {
  const app = Fastify({
    logger: {
      level: 'debug',
      timestamp: () => `,"time":"${new Date().toISOString()}"`,
    },
  });

  beforeAll(async () => {

    void app.register(fp(route));

    //register plugin
    app.register(snsTrnprescriptionChangedClient);
    await app.ready();
  });

  afterAll(() => app.close());

  return app;
}
