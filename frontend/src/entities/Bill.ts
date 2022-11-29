import { String, Array, Record, Static } from "runtypes";
import BillDto from "./BillDto";
import { getDefaultConfig, PdfConfigSchema } from "./PdfConfig";
import { ProductSchema, toProductDto } from "./Product";
import ProductDto from "./ProductDto";

export const BillSchema = Record({
  user: String.withConstraint((user) => user.length > 0),
  bill: Record({
    title: String.withConstraint((title) => title.length > 0),
    seller: String.withConstraint((seller) => seller.length > 0),
    purchaser: String.withConstraint((purchaser) => purchaser.length > 0),
    products: Array(ProductSchema),
  }),
  config: PdfConfigSchema,
});

type Bill = Static<typeof BillSchema>;
export default Bill;

export const getDefaultBill = (): Bill => {
  return {
    user: "",
    bill: {
      title: "",
      seller: "",
      purchaser: "",
      products: [],
    },
    config: getDefaultConfig(),
  };
};

export const toBillDto = (bill: Bill): BillDto => {
  const products: ProductDto[] = bill.bill.products.map((product) =>
    toProductDto(product)
  );

  return {
    ...bill,
    bill: {
      ...bill.bill,
      products,
    },
  };
};
