import { String, Number, Record, Static, InstanceOf } from "runtypes";

export const BillDescriptionSchema = Record({
  id: Number,
  title: String.withConstraint((title) => title.length > 0),
  timestamp: InstanceOf(Date),
});

type BillDescription = Static<typeof BillDescriptionSchema>;
export default BillDescription;
