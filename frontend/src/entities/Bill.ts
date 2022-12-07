import { z } from "zod";

export const BillSchema = z
  .object({
    id: z.number(),
    user: z.string(),
    title: z.string(),
    createdAt: z.date(),
    isAvailable: z.boolean(),
    error: z.boolean(),
    errorMessage: z.string(),
  })
  .strict();

type Bill = z.infer<typeof BillSchema>;
export default Bill;
