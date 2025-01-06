import { InhLogger } from '@inh-lib/common';
import { FastifyReply, FastifyRequest } from 'fastify';
import {
  Handler,
  inputDTO,
  InputDTO,
  OutputDTO,
  parseDTOToModel,
  parseResultToSuccessDTO,
} from '@gu-example-system/exm-api-service/command/create-bible';
import { DataParser } from '@gu-example-system/exm-api-core';
import {
  Failures,
  InputModel,
  OutputModel,
  Repository,
} from '@gu-example-system/exm-api-core/command/create-bible';
import { PrismaClient, getPrismaInstance } from '@gu-example-system/exm-data-store-prisma';
import { CreateBibleRepo } from '@gu-example-system/exm-data-store-prisma/bible-factory/command/create-bible';
type CreateBibleRequest = FastifyRequest<{
  Body: {
    country: string;
    year: number;
    species: { speciesCode: string; speciesName: string };
    animalType: [];
    items: string[];
    medType?: { medTypeCode: string; medTypeName: string };
  };
  traceId: string;
}>;
export async function createBibleEndpoint(req: CreateBibleRequest, reply: FastifyReply):Promise<void> {
  const logger: InhLogger = req.log;

  const parseRequestData = inputDTO.safeParse({
    ...req.body,
    uid: req.accountUsername,
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

  const repository: Repository = new CreateBibleRepo(prismaClient, logger);

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
          error: error,
        });
      case Failures.CreateFail:
      case Failures.CheckConditionFail:
      case Failures.GetFail:
        return reply.status(400).send({
          success: false,
          message: error.errorValue().message,
          
        });
      default:
        return reply.status(500).send({
          success: false,
          message: 'Internal server error',
          traceId: req.traceId,
          error: error,
        });
    }
  }

  return reply.status(200).send({ success: true, data: result.value.getValue() });
}
