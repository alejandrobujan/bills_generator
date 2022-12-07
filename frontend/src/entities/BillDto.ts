import { z } from "zod";
import Bill, { BillSchema } from "./Bill";

export const BillDtoSchema = z
  .object({
    id: z.number(),
    user: z.string(),
    title: z.string(),
    created_at: z.date(),
    is_available: z.boolean(),
    error: z.boolean(),
    error_msg: z.string(),
  })
  .strict();

type BillDto = z.infer<typeof BillDtoSchema>;
export default BillDto;

export const toBill = (dto: BillDto): Bill => {
  return BillSchema.parse({
    id: dto.id,
    user: dto.user,
    title: dto.title,
    createdAt: new Date(dto.created_at),
    isAvailable: dto.is_available,
    error: dto.error,
    errorMessage: dto.error_msg,
  });
};
