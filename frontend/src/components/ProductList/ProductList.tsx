import { FormEvent, useState } from "react";
import Product from "../../entities/Product";
import NormalButton from "../Buttton/NormalButton";
import NumberInput from "../Input/NumberInput";
import TextInput from "../Input/TextInput";
import styles from "./productList.module.scss";
import AddIcon from "@mui/icons-material/Add";

interface Props {
  products: Product[];
}

function ListItem(product: Product) {
  return (
    <div className={styles.ProductList_item}>
      <span>{product.name}</span>
      <span>{product.price}</span>
    </div>
  );
}

export default function ProductList({ products }: Props) {
  const [formState, setFormState] = useState<{
    name: string;
    price: number;
    quantity: number;
  }>({
    name: "",
    price: 0,
    quantity: 0,
  });

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    e.stopPropagation();
    console.log("Submit");
  }

  return (
    <form className={styles.ProductList_container} onSubmit={handleSubmit}>
      <div className={styles.ProductList_row}>
        <span>Product</span>
        <span>Quantity</span>
        <span>Price</span>
      </div>
      <div className={styles.ProductList_row}>
        <TextInput
          required
          value={formState.name}
          onChange={(name) => setFormState({ ...formState, name })}
        />
        <NumberInput
          required
          value={formState.quantity}
          onChange={(quantity) => setFormState({ ...formState, quantity })}
        />
        <NumberInput
          required
          value={formState.price}
          onChange={(price) => setFormState({ ...formState, price })}
        />

        <NormalButton type="submit" className={styles.ProductList_addButton}>
          <AddIcon />
        </NormalButton>
      </div>
      <div className={styles.ProductList_body}>
        {products.map((product) => ListItem(product))}
      </div>
    </form>
  );
}
