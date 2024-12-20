import z from 'zod';
export const inputDTO = z.object({
    id: z.string(),
    page: z.string().regex(/^\d+$/).transform(Number).optional(),
    size: z.string().regex(/^\d+$/).transform(Number).optional(),
    search: z.string().optional(),
});

export type InputDTO = z.infer<typeof inputDTO>;

export const items = z.array(
    z.object({
        id: z.string(),
        status: z.string(),
        medCode: z.string(),
        medGroup: z.string(),
        stopPeriod: z.string(),
        medId: z.string(),
        ingredient: z.array(
            z.object({
                activeIngredient: z.string(),
                qty: z.number(),
            })
        ),

    }))
export const OutputBible = z.object({
    id: z.string(),
    species: z.object({
        speciesCode: z.string(),
        speciesName: z.string(),
    }),
    status: z.string(),
    country: z.object({
        countryCode: z.string(),
        countryName: z.string(),
    }),
    animalType: z.array(z.object({
        animalTypeCode: z.string(),
        animalTypeName: z.string(),
    })),
    medType: z.object({
        medTypeCode: z.string(),
        medTypeName: z.string(),
    }),
    // veterinarianName: z.string(),
    // veterinarianCode: z.string(),
    // docNo: z.string(),
    remarks: z.string(),
    createBy: z.string(),
    updateBy: z.string(),
    createAt: z.date(),
    updateAt: z.date(),
    cancelRemark: z.string(),
    year: z.number(),
    items: items,
    total: z.number(),
});
export type OutputDTO = z.infer<typeof OutputBible>;
