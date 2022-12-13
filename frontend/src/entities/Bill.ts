import { z } from "zod";

export const BillSchema = z
  .object({
    id: z.number(),
    user: z.string().nullable(),
    title: z.string().nullable(),
    createdAt: z.date(),
    isAvailable: z.boolean(),
    error: z.boolean(),
    errorMessage: z.string().nullable(),
  })
  .strict();

type Bill = z.infer<typeof BillSchema>;
export default Bill;
