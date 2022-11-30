import { String, Number, Record, Static } from "runtypes";
import BillDescription from "./BillDescription";

export const BillDescriptionDtoSchema = Record({
  id: Number,
  title: String.withConstraint((title) => title.length > 0),
  created_at: String,
});

type BillDescriptionDto = Static<typeof BillDescriptionDtoSchema>;
export default BillDescriptionDto;

export const toBillDescription = (dto: BillDescriptionDto): BillDescription => {
  return {
    id: dto.id,
    title: dto.title,
    createdAt: new Date(dto.created_at),
  };
};
