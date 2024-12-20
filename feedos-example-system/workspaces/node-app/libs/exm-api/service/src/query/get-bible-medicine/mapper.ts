import { Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from './dto';
import { DataParser } from '@fos-psc-webapi/bible-factory-core';
import { InputModel, OutputModel } from '@fos-psc-webapi/bible-factory-core/query/get-bible-medicine';

export const parseDTOToModel: DataParser<InputDTO, InputModel> = (rawData: InputDTO): Result<InputModel> => {
  const result: InputModel = {
    page: rawData.page,
    size: rawData.size,
    search: rawData.search,
    countryCode: rawData.countryCode,
    medicineTypeCode: rawData.medicineTypeCode,
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
