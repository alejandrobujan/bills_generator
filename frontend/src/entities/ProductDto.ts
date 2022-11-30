import { Number, String, Record, Static } from "runtypes";
import { v4 } from "uuid";
import Product from "./Product";

export const ProductDtoSchema = Record({
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

type ProductDto = Static<typeof ProductDtoSchema>;
export default ProductDto;

export const getDefaultProductDto = (): ProductDto => {
  return {
    name: "",
    price: 0,
    quantity: 0,
  };
};

export const toProduct = (dto: ProductDto): Product => {
  return {
    id: v4(),
    name: dto.name,
    price: dto.price,
    quantity: dto.quantity,
  };
};
