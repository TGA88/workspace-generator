import { ResultV2 as Result, BaseFailure } from '@inh-lib/common';
import { UnifiedHttpContext } from '@inh-lib/unified-route';

export interface Repository {
  get__Domain__(
    context: UnifiedHttpContext,
    props: Get__Domain__Input,
  ): Promise<Result<Get__Domain__Output, BaseFailure>>;
}

// ─── Input / Output types ────────────────────────
export type Get__Domain__Input = {
  id: string;
};

export type Get__Domain__Output = {
  id: string;
  name: string;
  sku: string;
  price: number;
  description?: string;
};
