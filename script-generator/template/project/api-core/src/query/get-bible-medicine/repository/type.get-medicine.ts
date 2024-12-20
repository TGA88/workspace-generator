import { Items } from '../model';

export type GetMedicineInput = {
  page?: number;
  size?: number;
  search?: string | null;
  countryCode: string;
  medicineTypeCode: string;
  speciesCode?: string;
};

export type GetMedicineOutput = {
  items: Items[];
  total: number;
};
