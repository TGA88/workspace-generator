export type GetAllAnimalTypeInput = {
  id: string;
  year: number;
};

export type GetAllAnimalTypeOutput = {
  animalType: { animalTypeCode: string; animalTypeName: string }[];
  year: number;
  // animalType: string[];
};
