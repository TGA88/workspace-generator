export type InputModel = {
  page?: number;
  size?: number;
  search?: string | null;
  countryCode: string;
  medicineTypeCode: string;
  speciesCode?: string;
};

export type Items = {
  id: string;
  medCode: string;
  medName: string;
};

export type OutputModel = {
  items: Items[];
  total: number;
};
