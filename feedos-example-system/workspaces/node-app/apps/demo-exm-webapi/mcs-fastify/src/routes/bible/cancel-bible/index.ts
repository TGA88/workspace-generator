import { FastifyInstance, FastifyPluginAsync, preValidationHookHandler } from 'fastify';
import { cancelBibleEndpoint } from './endpoint';
// import { jwtAuth } from '@feed-portalshared-system/api-utils';
// import { checkRole, getPermissionAndRole, getPscAccount } from '@api-utils/fastify-custom-hook';
// import { UserRole } from '@fos-psc-webapi/prescription-core';
import { getPermissionAndRole, getPscAccount } from '@feedos-example-system/api-plugin-fastify';
import { InhPublishCommandItf } from '@inh-lib/common';

const cancelBibleRoute: FastifyPluginAsync = async (fastify): Promise<void> => {
  fastify.put('/', {
    preValidation: [
      // jwtAuth(fastify),
      // getPscAccount(fastify),
      // getPermissionAndRole(fastify),
      // checkRole(fastify, [UserRole.Admin, UserRole.QCStaff])
      trnChangePublishCommand(fastify),
      getPscAccount(fastify),
      getPermissionAndRole(fastify),
    ],
    handler: cancelBibleEndpoint,
  });
};

declare module 'fastify' {
  export interface FastifyRequest {
    snsTrnPrescriptionChanged: InhPublishCommandItf
  }
}
function trnChangePublishCommand(fastify: FastifyInstance): preValidationHookHandler {
  fastify.addHook('preHandler', async (req, _reply) => {
    const topicArn = process.env.SNS_TRNPRESCRIPTION_CHANGED as string
    const publishCommand = fastify.producerClient.makePublishCommand(topicArn)
    req.snsTrnPrescriptionChanged = publishCommand

  })
  return (_req, _reply, done) => {
    done();
  };
}
export default cancelBibleRoute;
