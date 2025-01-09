export type InputModel = {
  id: string;
  year: number;
  animalType: {
    animalTypeCode: string,
    animalTypeName: string
  }[];
  uid?: string;
};

export type OutputModel = {
  id: string;
};
