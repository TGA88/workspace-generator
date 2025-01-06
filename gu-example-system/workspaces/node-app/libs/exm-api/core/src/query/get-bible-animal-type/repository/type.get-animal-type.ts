import { Items } from '../model';

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
