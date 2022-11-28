import { String, Array, Record, Static } from "runtypes";
import { PdfConfigSchema } from "./PdfConfig";
import { ProductDtoSchema } from "./ProductDto";

export const BillDtoSchema = Record({
  user: String.withConstraint((user) => user.length > 0),
  bill: Record({
    seller: String.withConstraint((seller) => seller.length > 0),
    purchaser: String.withConstraint((purchaser) => purchaser.length > 0),
    products: Array(ProductDtoSchema),
  }),
  config: PdfConfigSchema,
});

type BillDto = Static<typeof BillDtoSchema>;

export default BillDto;
