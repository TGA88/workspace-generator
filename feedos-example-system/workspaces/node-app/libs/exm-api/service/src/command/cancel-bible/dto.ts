import z from 'zod';

export const inputDTO = z.object({
  id: z.string(),
  cancelRemark: z.string(),
  uid: z.string().optional(),
});

export type InputDTO = z.infer<typeof inputDTO>;

export const OutputDTO = z.object({
  id: z.string(),
});

export type OutputDTO = z.infer<typeof OutputDTO>;
