import { z } from "zod";
import { v4 } from "uuid";
import Product, { ProductSchema } from "./Product";

export const ProductDtoSchema = z
  .object({
    name: z.string(),
    price: z.number(),
    quantity: z.number(),
    discount: z.number().optional(),
  })
  .strict();

type ProductDto = z.infer<typeof ProductDtoSchema>;
export default ProductDto;

export const getDefaultProductDto = (): ProductDto => {
  return ProductDtoSchema.parse({
    name: "",
    price: 0,
    quantity: 0,
    discount: undefined,
  });
};

export const toProduct = (dto: ProductDto): Product => {
  return ProductSchema.parse({
    id: v4(),
    name: dto.name,
    price: dto.price,
    quantity: dto.quantity,
    discount: dto.discount,
  });
};
