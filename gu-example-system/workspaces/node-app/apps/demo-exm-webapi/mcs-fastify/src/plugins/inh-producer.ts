import { AxSnsProducerProvider } from '@gu-example-system/api-communication-aws'
import {  InhProducerClientItf, InhProducerConfig, InhProducerProviderItf } from '@inh-lib/common'

import fp from 'fastify-plugin'

export default fp(async (fastify) => {
    fastify.log.info("init inhProducer ")
    const config: InhProducerConfig = {
        region: process.env.AWS_APPINTEGRATION_REGION as string,
        endpoint: process.env.SNS_ENDPOINT as string,
        credentials: {
            accessKeyId: process.env.AWS_APPINTEGRATION_ACCESS_KEY as string,
            secretAccessKey: process.env.AWS_APPINTEGRATION_SECRET_ACCESS_KEY as string,
        }
    }
    const provider = new AxSnsProducerProvider(fastify.inhLogger)
    const producerClient = provider.makeProducerClient(config)




    fastify.decorate('prodcuerClient', {
        producerClient: producerClient
    });

    fastify.decorate('prodcuerProvider', {
        producerProvider: provider
    });
})

declare module 'fastify' {
    export interface FastifyInstance {
        producerProvider: InhProducerProviderItf
        producerClient: InhProducerClientItf
    }
}