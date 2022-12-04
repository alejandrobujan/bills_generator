import { String, Array, Record, Static } from "runtypes";
import BillRequestDto from "./BillRequestDto";
import {
  getDefaultPdfConfig,
  PdfConfigSchema,
  toPdfConfigDto,
} from "./PdfConfig";
import { ProductSchema, toProductDto } from "./Product";
import ProductDto from "./ProductDto";

export const BillRequestSchema = Record({
  user: String.withConstraint((user) => user.length > 0),
  bill: Record({
    title: String.withConstraint((title) => title.length > 0),
    seller: String.withConstraint((seller) => seller.length > 0),
    purchaser: String.withConstraint((purchaser) => purchaser.length > 0),
    products: Array(ProductSchema),
  }),
  config: PdfConfigSchema,
});

type BillRequest = Static<typeof BillRequestSchema>;
export default BillRequest;

export const getDefaultBillRequest = (): BillRequest => {
  return {
    user: "",
    bill: {
      title: "",
      seller: "",
      purchaser: "",
      products: [],
    },
    config: getDefaultPdfConfig(),
  };
};

export const toBillRequestDto = (bill: BillRequest): BillRequestDto => {
  const products: ProductDto[] = bill.bill.products.map((product) =>
    toProductDto(product)
  );

  const config = toPdfConfigDto(bill.config);

  return {
    ...bill,
    bill: {
      ...bill.bill,
      products,
    },
    config,
  };
};
