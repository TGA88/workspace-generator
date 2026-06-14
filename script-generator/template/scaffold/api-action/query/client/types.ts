import { DataResponse } from '@inh-lib/common';

export type __Verb____Domain__Request = {
  id: string;
};

export type __Verb____Domain__Output = {
  id: string;
  name: string;
  sku: string;
  price: number;
  description?: string;
} | null;

export type __Verb____Domain__Response = DataResponse<__Verb____Domain__Output>;
