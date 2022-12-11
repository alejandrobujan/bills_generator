import { z } from "zod";
import ProductDto, { ProductDtoSchema } from "./ProductDto";

export const ProductSchema = z
  .object({
    id: z.string(),
    name: z.string(),
    price: z.number(),
    quantity: z.number(),
    discount: z.number().optional(),
  })
  .strict();

type Product = z.infer<typeof ProductSchema>;
export default Product;

export const toProductDto = (product: Product): ProductDto => {
  return ProductDtoSchema.parse({
    name: product.name,
    price: product.price,
    quantity: product.quantity,
    discount: product.discount,
  });
};
