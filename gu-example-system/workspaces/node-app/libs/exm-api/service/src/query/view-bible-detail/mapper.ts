import { InputDTO, OutputDTO } from "./dto";
import { DataParser } from '@gu-example-system/exm-api-core';

import {
    
    InputModel,
    OutputModel,
} from '@gu-example-system/exm-api-core/query/view-bible-detail'
import { Result } from "@inh-lib/common";

export const parseDTOToModel: DataParser<InputDTO, InputModel> = (
    rawData: InputDTO,
): Result<InputModel> => {
    const result: InputModel = {
        id: rawData.id,
        page: rawData.page,
        size: rawData.size,
        search: rawData.search
    };
    return Result.ok(result);
};

export const parseResultToSuccessDTO: DataParser<OutputModel, OutputDTO> = (
    rawData: OutputModel,
): Result<OutputDTO> => {
    const result: OutputDTO = {
        id: rawData.id,
        animalType: rawData.animalType,
        country: rawData.country,
        species: rawData.species,
        status: rawData.status,
        remarks: rawData.remarks,
        year: rawData.year,
        total: rawData.total,
        createAt: rawData.createAt,
        createBy: rawData.createBy,
        updateAt: rawData.updateAt,
        updateBy: rawData.updateBy,
        medType: rawData.medType,
        items: rawData.items,
        cancelRemark: rawData.cancelRemark


    };

    return Result.ok(result);
};