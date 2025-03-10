export type EditBibleInput = {
  id: string;
  country: { countryCode: string; countryName: string };
  year: number;
  species: { speciesCode: string; speciesName: string };
  // animalType: string[];
  animalType: { animalTypeCode: string; animalTypeName: string }[];
  medType?: { medTypeCode: string; medTypeName: string };
  uid?: string;
  remark?: string;
  updateBy?: string;
};

export type EditBibleOutput = {
  id: string;
};
