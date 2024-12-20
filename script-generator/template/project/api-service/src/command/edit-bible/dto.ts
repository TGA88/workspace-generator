import z from 'zod';

export const inputDTO = z.object({
  id: z.string(),
  remark: z.string().optional(),
  country: z.object({ countryCode: z.string(), countryName: z.string() }),
  year: z.number(),
  species: z.object({ speciesCode: z.string(), speciesName: z.string() }),
  animalType: z.array(z.object({ animalTypeCode: z.string(), animalTypeName: z.string() })),
  medType: z.object({ medTypeCode: z.string(), medTypeName: z.string() }).optional(),
  uid: z.string().optional(),
});

export type InputDTO = z.infer<typeof inputDTO>;

export const outputDTO = z.object({
  id: z.string(),
});

export type OutputDTO = z.infer<typeof outputDTO>;
