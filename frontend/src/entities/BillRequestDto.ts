import { z } from "zod";
import BillRequest, { BillRequestSchema } from "./BillRequest";
import {
  getDefaultPdfConfigDto,
  PdfConfigDtoSchema,
  toPdfConfig,
} from "./PdfConfigDto";
import Product from "./Product";
import { ProductDtoSchema, toProduct } from "./ProductDto";

export const BillRequestDtoSchema = z.object({
  user: z.string(),
  bill: z.object({
    title: z.string(),
    seller: z.string(),
    purchaser: z.string(),
    products: z.array(ProductDtoSchema),
    taxes: z.number(),
  }),
  config: PdfConfigDtoSchema,
});

type BillRequestDto = z.infer<typeof BillRequestDtoSchema>;
export default BillRequestDto;

export const toBillRequest = (dto: BillRequestDto): BillRequest => {
  const products: Product[] = dto.bill.products.map((product) =>
    toProduct(product)
  );

  const config = toPdfConfig({
    ...getDefaultPdfConfigDto(),
    ...dto.config,
  });

  return BillRequestSchema.parse({
    user: dto.user,
    bill: {
      ...dto.bill,
      products,
    },
    config,
  });
};
