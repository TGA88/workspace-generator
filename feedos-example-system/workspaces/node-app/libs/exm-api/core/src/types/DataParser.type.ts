import { Result } from '@inh-lib/common';

export type DataParser<I, O> = (input: I) => Result<O>;
