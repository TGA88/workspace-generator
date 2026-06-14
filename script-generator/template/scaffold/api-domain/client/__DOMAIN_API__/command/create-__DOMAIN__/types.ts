import { DataResponse } from '@inh-lib/common';

export type Create__Domain__Request = {
  name: string;
  sku: string;
  price: number;
  description?: string;
};

export type Create__Domain__Output = {
  id: string;
  sku: string;
} | null;

export type Create__Domain__Response = DataResponse<Create__Domain__Output>;
