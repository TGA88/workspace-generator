import { Result } from "@inh-lib/common";
import { DeleteBibleInput, DeleteBibleOutput } from "./type.deleteBible";
import { CheckBibleStatusInput, CheckBbibleStatusOutput } from "./type.checkBibleStatus";
// import { HasPrescriptionDetailInput, HasPrescriptionDetailOutput } from "./type.has-prescription-detail";
// import { DeletePrescriptionDetailInput, DeletePrescriptionDetailOutput } from "./type.deletePrescriptionDetail";

export interface Repository {
	checkBibleStatus(props: CheckBibleStatusInput): Promise<Result<CheckBbibleStatusOutput>>
	deleteBible(props: DeleteBibleInput): Promise<Result<DeleteBibleOutput>>;
	// hasPrescriptionDetail(input: HasPrescriptionDetailInput): Promise<Result<HasPrescriptionDetailOutput>>;
	// deletePrescriptionDetail(props: DeletePrescriptionDetailInput): Promise<Result<DeletePrescriptionDetailOutput>>;

}