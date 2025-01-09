export type InputModel = {
  id: string;
  country: { countryCode: string; countryName: string };
  year: number;
  species: { speciesCode: string; speciesName: string };
  // animalType: string[];
  animalType: { animalTypeCode: string; animalTypeName: string }[];
  medType?: { medTypeCode: string; medTypeName: string };
  uid?: string;
  remark?: string;
};

export type OutputModel = {
  id: string;
};
