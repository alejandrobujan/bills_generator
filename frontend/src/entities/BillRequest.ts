import { z } from "zod";
import BillRequestDto, { BillRequestDtoSchema } from "./BillRequestDto";
import {
  getDefaultPdfConfig,
  PdfConfigSchema,
  toPdfConfigDto,
} from "./PdfConfig";
import { ProductSchema, toProductDto } from "./Product";
import ProductDto from "./ProductDto";

export const BillRequestSchema = z
  .object({
    user: z.string(),
    bill: z.object({
      title: z.string(),
      seller: z.string(),
      purchaser: z.string(),
      products: z.array(ProductSchema),
      taxes: z.number(),
    }),
    config: PdfConfigSchema,
  })
  .strict();

type BillRequest = z.infer<typeof BillRequestSchema>;
export default BillRequest;

export const getDefaultBillRequest = (): BillRequest => {
  return BillRequestSchema.parse({
    user: "",
    bill: {
      title: "",
      seller: "",
      purchaser: "",
      products: [],
      taxes: 0,
    },
    config: getDefaultPdfConfig(),
  });
};

export const toBillRequestDto = (bill: BillRequest): BillRequestDto => {
  const products: ProductDto[] = bill.bill.products.map((product) =>
    toProductDto(product)
  );

  const config = toPdfConfigDto(bill.config);

  return BillRequestDtoSchema.parse({
    ...bill,
    bill: {
      ...bill.bill,
      products,
    },
    config,
  });
};
