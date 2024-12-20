export type GetAllAnimalTypeInput = {
  year: number;
};

export type GetAllAnimalTypeOutput = {
  animalType: { animalTypeCode: string; animalTypeName: string }[];
  // animalType: string[];
};
