export type GetBibleDetailInput = {
  id: string;
};

export type GetBibleDetailOutput = {
  id: string;
  country: { countryCode: string; countryName: string };
  year: number;
  species: { speciesCode: string; speciesName: string };
  animalType: { animalTypeCode: string; animalTypeName: string }[];
  // animalType: string[];
  medType?: { medTypeCode: string; medTypeName: string };
  remark?: string;
  bibleStatus: string;
};
