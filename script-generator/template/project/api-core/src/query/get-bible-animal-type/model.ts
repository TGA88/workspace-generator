export type InputModel = {
  page?: number;
  size?: number;
  search?: string;
  speciesCode?: string;
};

export type Items = {
  id: string;
  animalTypeCode: string;
  animalTypeName: string;
};

export type OutputModel = {
  items: Items[];
  total: number;
};
