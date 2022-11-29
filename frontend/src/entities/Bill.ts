import { String, Array, Record, Static } from "runtypes";
import BillDto from "./BillDto";
import { getDefaultConfig, PdfConfigSchema } from "./PdfConfig";
import { ProductSchema } from "./Product";
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

export const getDefaultBill = () => {
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
  const newProducts: ProductDto[] = bill.bill.products.map((product) => {
    return {
      name: product.name,
      price: product.price,
      quantity: product.quantity,
    };
  });

  return {
    user: bill.user,
    bill: {
      ...bill.bill,
      products: newProducts,
    },
    config: bill.config,
  };
};
