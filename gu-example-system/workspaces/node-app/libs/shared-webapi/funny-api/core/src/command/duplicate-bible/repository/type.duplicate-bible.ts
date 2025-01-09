export type DuplicateBibleInput = {
  id: string;
  animalType: { animalTypeCode: string; animalTypeName: string }[];
  year: number;
  uid?: string;
  bibleStatus: string;
  createBy?: string;

};

export type DuplicateBibleOutput = {
  id: string;
};
