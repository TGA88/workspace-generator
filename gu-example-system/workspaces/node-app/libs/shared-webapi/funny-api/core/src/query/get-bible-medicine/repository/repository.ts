import { Result } from "@inh-lib/common";
import { GetMedicineInput, GetMedicineOutput } from "./type.get-medicine";

export interface Repository {
	getMedicine(input: GetMedicineInput): Promise<Result<GetMedicineOutput>>;
}