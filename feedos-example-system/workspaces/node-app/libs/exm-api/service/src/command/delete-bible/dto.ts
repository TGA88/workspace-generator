import z from 'zod';

export const inputDTO = z.object({
	id: z.string()
});

export type InputDTO = z.infer<typeof inputDTO>;

export const outputDTO = z.object({
	id: z.string()
});

export type OutputDTO = z.infer<typeof outputDTO>;
