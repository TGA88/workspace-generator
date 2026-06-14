import { DataResponse } from '@inh-lib/common';

export type Get__Domain__Request = {
  id: string;
};

export type Get__Domain__Output = {
  id: string;
  name: string;
  sku: string;
  price: number;
  description?: string;
} | null;

export type Get__Domain__Response = DataResponse<Get__Domain__Output>;
