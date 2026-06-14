export type Create__Domain__Input = {
  name: string;
  sku: string;
  price: number;
  description?: string;
  createBy?: string;
};

export type Create__Domain__Output = {
  id: string;
  sku: string;
};

export type CheckDuplicateSkuInput = {
  sku: string;
};

export type CheckDuplicateSkuOutput = {
  isDuplicate: boolean;
};
