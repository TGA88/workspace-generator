import z from 'zod';

export const inputDTO = z.object({
  page: z.string().regex(/^\d+$/).transform(Number).optional(),
  size: z
    .string()
    .regex(/^\d+$/)
    .transform(Number)
    .optional()
    .refine((size) => (size as number) <= 250, {
      message: 'Size must be less than or equal to 250',
    }),
  search: z.string().optional().nullable(),
  countryCode: z.string(),
  medicineTypeCode: z.string(),
  speciesCode: z.string().optional(),
});

export type InputDTO = z.infer<typeof inputDTO>;

export const medicineItemsTemplate = z.object({
  id: z.string(),
  medCode: z.string(),
  medName: z.string(),
});

export const OutputDTO = z.object({
  items: z.array(medicineItemsTemplate),
  total: z.number(),
});

export type OutputDTO = z.infer<typeof OutputDTO>;
