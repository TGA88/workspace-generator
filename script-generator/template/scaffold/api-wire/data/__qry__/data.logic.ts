import { Raw__Domain__ } from './internal.type';
import { Get__Domain__Output } from '@__WS__/__API__-core/__DOMAIN_API__/query/get-__DOMAIN__';

// Pure transform: raw (prisma) → core Output
export function transform__Domain__ToOutput(raw: Raw__Domain__): Get__Domain__Output {
  return {
    id: raw.id,
    name: raw.name,
    sku: raw.sku,
    price: raw.price,
    description: raw.description ?? undefined,
  };
}
