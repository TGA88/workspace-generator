import { InputDTO, OutputDTO } from './dto';
import { DataParser } from '@feedos-example-system/exm-api-core';
import { InputModel,OutputModel} from '@feedos-example-system/exm-api-core/query/get-bible-animal-type';
import { Result } from '@inh-lib/common';

export const parseDTOToModel: DataParser<InputDTO, InputModel> = (rawData: InputDTO): Result<InputModel> => {
  const result: InputModel = {
    page: rawData.page,
    size: rawData.size,
    search: rawData.search,
    speciesCode: rawData.speciesCode,
  };
  return Result.ok(result);
};

export const parseResultToSuccessDTO: DataParser<OutputModel, OutputDTO> = (
  rawData: OutputModel,
): Result<OutputDTO> => {
  const result: OutputDTO = {
    items: rawData.items,
    total: rawData.total,
  };

  return Result.ok(result);
};
