import { Raw__Domain__ } from './internal.type';
import { Create__Domain__Output } from '@__WS__/__API__-core/__DOMAIN_API__/command/create-__DOMAIN__';

// Pure transform: raw (prisma) → core Output
export function transform__Domain__ToOutput(raw: Raw__Domain__): Create__Domain__Output {
  return { id: raw.id, sku: raw.sku };
}
