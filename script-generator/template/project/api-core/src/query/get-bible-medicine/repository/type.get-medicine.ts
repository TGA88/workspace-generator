

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

export type Items = {
  id: string;
  medCode: string;
  medName: string;
};
