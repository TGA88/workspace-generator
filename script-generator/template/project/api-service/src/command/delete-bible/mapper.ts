import { Result } from '@inh-lib/common';
import { InputDTO, OutputDTO } from './dto';
import { DataParser } from '@gu-example-system/exm-api-core';

import {
	InputModel,
	OutputModel,
} from '@gu-example-system/exm-api-core/command/delete-bible'

export const parseDTOToModel: DataParser<InputDTO, InputModel> = (
	rawData: InputDTO,
): Result<InputModel> => {
	const result: InputModel = {
		id: rawData.id
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
