import { z } from 'zod';

export const inputDTO = z.object({
  id: z.string(),
  year: z.number(),
  animalType: z.array(z.object({ animalTypeCode: z.string(), animalTypeName: z.string() })),
  uid: z.string().optional(),

});

export type InputDTO = z.infer<typeof inputDTO>;

export const outputDTO = z.object({
  id: z.string(),
});

export type OutputDTO = z.infer<typeof outputDTO>;
