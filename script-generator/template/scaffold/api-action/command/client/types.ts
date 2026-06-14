import { DataResponse } from '@inh-lib/common';

export type __Verb____Domain__Request = {
  name: string;
  sku: string;
  price: number;
  description?: string;
};

export type __Verb____Domain__Output = {
  id: string;
  sku: string;
} | null;

export type __Verb____Domain__Response = DataResponse<__Verb____Domain__Output>;
