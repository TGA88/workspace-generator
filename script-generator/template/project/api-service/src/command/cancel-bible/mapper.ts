import { Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from './dto';
import { DataParser } from '@feedos-example-system/exm-api-core';
import { InputModel, OutputModel } from '@feedos-example-system/exm-api-core/command/cancel-bible';

export const parseDTOToModel: DataParser<InputDTO, InputModel> = (rawData: InputDTO): Result<InputModel> => {
  const result: InputModel = {
    id: rawData.id,
    cancelRemark: rawData.cancelRemark,
    uid: rawData.uid,
  };
  return Result.ok(result);
};

export const parseResultToSuccessDTO: DataParser<OutputModel, OutputDTO> = (
  rawData: OutputModel,
): Result<OutputDTO> => {
  const result: OutputDTO = {
    id: rawData.id,
  };

  return Result.ok(result);
};