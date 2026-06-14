import { z } from 'zod';

export const inputDTO = z.object({
  id: z.string(),
});
export type InputDTO = z.infer<typeof inputDTO>;

export const outputDTO = z.object({
  id: z.string(),
  name: z.string(),
  sku: z.string(),
  price: z.number(),
  description: z.string().optional(),
});
export type OutputDTO = z.infer<typeof outputDTO>;
