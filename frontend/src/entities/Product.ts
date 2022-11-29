import { Number, String, Record, Static } from "runtypes";
import ProductDto from "./ProductDto";

export const ProductSchema = Record({
  id: String,
  name: String.withConstraint(
    (name) => name.length > 0 || "Name must be at least 1 character long"
  ),
  price: Number.withConstraint(
    (price) => price >= 0 || "Price must be greater than or equal to 0"
  ),
  quantity: Number.withConstraint(
    (quantity) => quantity >= 0 || "Quantity must be greater than or equal to 0"
  ),
});

type Product = Static<typeof ProductSchema>;
export default Product;

export const toProductDto = (product: Product): ProductDto => {
  return {
    name: product.name,
    price: product.price,
    quantity: product.quantity,
  };
};
