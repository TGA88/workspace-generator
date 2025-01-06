// import {  InhPublishCommandItf } from '@inh-lib/common'


import fp from 'fastify-plugin'

// export default fp(async (fastify) => {
//     fastify.log.info("init snsTrnPrescriptionChanged ")
//     const topicArn= process.env.SNS_TRNPRESCRIPTION_CHANGED as string
//     const publishCommand = fastify.producerClient.makePublishCommand(topicArn)

//     fastify.decorate('snsTrnPrescriptionChanged', {
//         client: publishCommand
//     });
// })

// declare module 'fastify' {
//     export interface FastifyInstance {
//         snsTrnPrescriptionChanged: {
//             client: InhPublishCommandItf
//         }
//     }
// }
export default fp(async (fastify) => { 
    fastify.log.info("sns_trn_change")
})