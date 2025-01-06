export type CreateBibleInput = {
  country: { countryCode: string; countryName: string };
  year: number;
  species: { speciesCode: string; speciesName: string };
  // animalType: string[];
  animalType: { animalTypeCode: string; animalTypeName: string }[];
  items: string[];
  uid?: string;
  createBy?: string;
  medType?: { medTypeCode: string; medTypeName: string };
};

export type CreateBibleOutput = {
  id: string;
};
