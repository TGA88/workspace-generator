import { InhLogger } from '@inh-lib/common';
import { FastifyReply, FastifyRequest } from 'fastify';
import {
  Handler,
  inputDTO,
  InputDTO,
  OutputDTO,
  parseDTOToModel,
  parseResultToSuccessDTO
} from '@feedos-example-system/exm-api-service/command/cancel-bible';

import { DataParser } from '@feedos-example-system/exm-api-core';
import {
  Failures,
  InputModel,
  OutputModel,
  Repository,
} from '@feedos-example-system/exm-api-core/command/cancel-bible';
import { PrismaClient, getPrismaInstance } from '@feedos-example-system/exm-data-store-prisma';
import {CancelBibleRepo } from '@feedos-example-system/exm-data-store-prisma/bible-factory/command/cancel-bible';
// import {CancelBibleRepo} from '@feedos-example-system/exm-data-store-prisma/bible-factory/command/cancel-bible';
type CancelBibleRequest = FastifyRequest<{
  Body: {
    id: string;
    cancelRemark: string;
  };
  traceId: string;
}>;
export async function cancelBibleEndpoint(req: CancelBibleRequest, reply: FastifyReply):Promise<void> {
  const logger: InhLogger = req.log;
  

  const parseRequestData = inputDTO.safeParse({
    ...req.body,
    uid: 1,
  });
  if (parseRequestData.success === false) {
    req.log.error({ error: parseRequestData.error });
    return reply.status(422).send({
      success: false,
      message: 'Validate request fail',
      
      error: parseRequestData.error,
    });
  }

  const prismaClient: PrismaClient = getPrismaInstance();

  const repository: Repository = new CancelBibleRepo(prismaClient, logger);

  const mapperToModel: DataParser<InputDTO, InputModel> = parseDTOToModel;
  const mapperSuccess: DataParser<OutputModel, OutputDTO> = parseResultToSuccessDTO;

  const handler = new Handler(mapperToModel, mapperSuccess, repository, logger);

  const result = await handler.execute(parseRequestData.data);

  if (result.isLeft()) {
    
    const error = result.value;

  
    logger.error({ message: 'error', error: error });
    switch (error.constructor) {
      case Failures.ParseFail:
        return reply.status(422).send({
          success: false,
          message: 'Validate request fail',
          // trace: req.traceId,
          error: error,
        });
      case Failures.UpdateFail:
      case Failures.CheckConditionFail:
      case Failures.GetFail:
        return reply.status(400).send({
          success: false,
          message: error.errorValue().message,
          // trace: req.traceId,
        });
      default:
        return reply.status(500).send({
          success: false,
          message: 'Internal server error',
          // trace: req.traceId,
          error: error,
        });
    }
  }

  return reply.status(200).send({ success: true, data: result.value.getValue() });
}
