import { String, Number, Record, Static, Boolean } from "runtypes";
import Bill from "./Bill";

export const BillDtoSchema = Record({
  id: Number,
  title: String,
  created_at: String,
  user: String,
  is_available: Boolean,
  error: Boolean,
  error_msg: String,
});

type BillDto = Static<typeof BillDtoSchema>;
export default BillDto;

export const toBill = (dto: BillDto): Bill => {
  return {
    id: dto.id,
    user: dto.user,
    title: dto.title,
    createdAt: new Date(dto.created_at),
    isAvailable: dto.is_available,
    error: dto.error,
    errorMessage: dto.error_msg,
  };
};
