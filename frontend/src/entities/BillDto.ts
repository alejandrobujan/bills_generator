import { String, Array, Record, Static } from "runtypes";
import { v4 } from "uuid";
import Bill from "./Bill";
import { getDefaultConfig, PdfConfigSchema } from "./PdfConfig";
import Product from "./Product";
import { ProductDtoSchema } from "./ProductDto";

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
  const newProducts: Product[] = dto.bill.products.map((product) => {
    return {
      id: v4(),
      name: product.name,
      price: product.price,
      quantity: product.quantity,
    };
  });

  const newConfig = {
    ...getDefaultConfig(),
    ...dto.config,
  };

  return {
    user: dto.user,
    bill: {
      ...dto.bill,
      products: newProducts,
    },
    config: newConfig,
  };
};
