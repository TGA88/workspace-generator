import { Result } from "@inh-lib/common";
import { GetDetailBibleInput, GetDetailBibleOutput } from "./type.get-detail-bible";
import { GetBibleDetailOfBibleOutPut, GetBibleDetailOfBibleInput } from "./type.get-bible-detail-of-bible";

export interface Repository {
	getDetailBible(input: GetDetailBibleInput): Promise<Result<GetDetailBibleOutput>>;
	getBibleDetailOfItems(props: GetBibleDetailOfBibleInput): Promise<Result<GetBibleDetailOfBibleOutPut>>
}