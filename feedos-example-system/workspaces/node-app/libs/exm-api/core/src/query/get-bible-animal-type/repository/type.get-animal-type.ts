
// input output สำหรับ db
export type GetAnimalTypeInput = {
  page?: number;
  size?: number;
  search?: string;
  speciesCode?: string;
};

export type GetAnimalTypeOutput = {
  items: Items[];
  total: number;
};

export type Items = {
  id: string;
  animalTypeCode: string;
  animalTypeName: string;
};