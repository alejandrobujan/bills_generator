import { String, Array, Record, Static } from "runtypes";
import Bill from "./Bill";
import { getDefaultConfig, PdfConfigSchema } from "./PdfConfig";
import Product from "./Product";
import { ProductDtoSchema, toProduct } from "./ProductDto";

export const BillDtoSchema = Record({
  user: String.withConstraint((user) => user.length > 0),
  bill: Record({
    title: String.withConstraint((title) => title.length > 0),
    seller: String.withConstraint((seller) => seller.length > 0),
    purchaser: String.withConstraint((purchaser) => purchaser.length > 0),
    products: Array(ProductDtoSchema),
  }),
  config: PdfConfigSchema,
});

type BillDto = Static<typeof BillDtoSchema>;
export default BillDto;

export const toBill = (dto: BillDto): Bill => {
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
