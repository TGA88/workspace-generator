import { InputDTO, OutputDTO } from './dto';
import { Result } from '@inh-lib/common';
import { DataParser } from '@gu-example-system/exm-api-core';
import { InputModel, OutputModel } from '@gu-example-system/exm-api-core/command/duplicate-bible';

export const parseToModel: DataParser<InputDTO, InputModel> = (rawData: InputDTO): Result<InputModel> => {
  const props: InputModel = {
    id: rawData.id,
    year: rawData.year,
    animalType: rawData.animalType,
    uid: rawData.uid,
  };
  return Result.ok(props);
};

export const parseResultToSuccessDTO: DataParser<OutputModel, OutputDTO> = (rawData: OutputModel): Result<OutputDTO> => {
  const props: OutputDTO = {
    id: rawData.id,
  };
  return Result.ok(props);
};
