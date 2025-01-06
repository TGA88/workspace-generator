import { FastifyPluginAsync } from 'fastify';
import { createBibleEndpoint } from './endpoint';
// import { jwtAuth } from '@gu-portalshared-system/api-utils';
import {  getPermissionAndRole, getPscAccount } from '@gu-example-system/api-plugin-fastify';
// import { UserRole } from '@fos-psc-webapi/prescription-core';


const createBibleRoute: FastifyPluginAsync = async (fastify): Promise<void> => {
  fastify.post('/', {
    preValidation: [
      getPscAccount(fastify),
      getPermissionAndRole(fastify),
      // checkRole(fastify, [UserRole.Admin, UserRole.QCStaff])
    ],
    handler: createBibleEndpoint,
  });
};

export default createBibleRoute;
