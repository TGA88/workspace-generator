import z from 'zod';
export const inputDTO = z.object({
  page: z.string().regex(/^\d+$/).transform(Number).optional(),
  size: z
    .string()
    .regex(/^\d+$/)
    .transform(Number)
    .optional()
    .refine((size) => (size as number) <= 100, {
      message: 'Size must be less than or equal to 100',
    }),
  search: z.string().optional(),
  speciesCode: z.string().optional(),
});

export type InputDTO = z.infer<typeof inputDTO>;

export const outDTO = z.object({
  items: z.array(
    z.object({
      id: z.string(),
      animalTypeCode: z.string(),
      animalTypeName: z.string(),
    }),
  ),
  total: z.number(),
});

export type OutputDTO = z.infer<typeof outDTO>;
