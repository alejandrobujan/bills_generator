import { String, Array, Record, Static } from "runtypes";
import BillRequest from "./BillRequest";
import { getDefaultConfig, PdfConfigSchema } from "./PdfConfig";
import Product from "./Product";
import { ProductDtoSchema, toProduct } from "./ProductDto";

export const BillRequestDtoSchema = Record({
  user: String.withConstraint((user) => user.length > 0),
  bill: Record({
    title: String.withConstraint((title) => title.length > 0),
    seller: String.withConstraint((seller) => seller.length > 0),
    purchaser: String.withConstraint((purchaser) => purchaser.length > 0),
    products: Array(ProductDtoSchema),
  }),
  config: PdfConfigSchema,
});

type BillRequestDto = Static<typeof BillRequestDtoSchema>;
export default BillRequestDto;

export const toBillRequest = (dto: BillRequestDto): BillRequest => {
  const products: Product[] = dto.bill.products.map((product) =>
    toProduct(product)
  );

  const config = {
    ...getDefaultConfig(),
    ...dto.config,
  };

  return {
    user: dto.user,
    bill: {
      ...dto.bill,
      products,
    },
    config,
  };
};
