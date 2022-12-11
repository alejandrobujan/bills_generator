import { z } from "zod";
import ProductDto, { ProductDtoSchema } from "./ProductDto";

export const ProductSchema = z
  .object({
    id: z.string(),
    name: z.string().min(1),
    price: z.number().min(0),
    quantity: z.number().min(1),
    discount: z.number().min(0).max(100).optional(),
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
