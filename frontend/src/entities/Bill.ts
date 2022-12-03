import { String, Number, Record, Static, InstanceOf, Boolean } from "runtypes";

export const BillSchema = Record({
  id: Number,
  user: String,
  title: String.withConstraint((title) => title.length > 0),
  createdAt: InstanceOf(Date),
  isAvailable: Boolean,
  error: Boolean,
  errorMessage: String,
});

type Bill = Static<typeof BillSchema>;
export default Bill;
