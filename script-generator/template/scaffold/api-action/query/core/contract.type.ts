import { ResultV2 as Result, BaseFailure } from '@inh-lib/common';
import { UnifiedHttpContext } from '@inh-lib/unified-route';

export interface Repository {
  __verb____Domain__(
    context: UnifiedHttpContext,
    props: __Verb____Domain__Input,
  ): Promise<Result<__Verb____Domain__Output, BaseFailure>>;
}

// ─── Input / Output types ────────────────────────
export type __Verb____Domain__Input = {
  id: string;
};

export type __Verb____Domain__Output = {
  id: string;
  name: string;
  sku: string;
  price: number;
  description?: string;
};
