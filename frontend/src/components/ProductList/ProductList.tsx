import { MouseEvent, useState } from "react";
import Product from "../../entities/Product";
import NormalButton from "../Buttton/NormalButton";
import NumberInput from "../Input/NumberInput";
import TextInput from "../Input/TextInput";
import styles from "./productList.module.scss";
import AddIcon from "@mui/icons-material/Add";
import { useNotifications } from "../NotificationManager/NotificationManager";
import { AnimatePresence, motion } from "framer-motion";

interface Props {
  products: Product[];
  onAddProduct: (product: Product) => void;
}

function ListItem(product: Product) {
  return (
    <motion.div
      layout
      transition={{ type: "spring", bounce: 0, duration: 0.4 }}
      initial={{ left: "-20%", opacity: 0 }}
      animate={{ left: 0, opacity: 1 }}
      exit={{ left: "-20%", opacity: 0 }}
      className={`${styles.ProductList_item} ${styles.ProductList_row}`}
    >
      <span>{product.name}</span>
      <span>{product.quantity} uds.</span>
      <span>{product.price}$</span>
    </motion.div>
  );
}

export default function ProductList({ products, onAddProduct }: Props) {
  const { createErrorNotification } = useNotifications();
  const defaultProduct = {
    name: "",
    price: 0,
    quantity: 0,
  };
  const [productFields, setProductFields] = useState<{
    name: string;
    price: number;
    quantity: number;
  }>(defaultProduct);

  function handleClick(_: MouseEvent<HTMLButtonElement>) {
    const product = Product.getInstance(
      productFields.name,
      productFields.price,
      productFields.quantity
    );
    if (product === null) {
      createErrorNotification("Product name is required", 10000);
      return;
    }
    setProductFields(defaultProduct);
    onAddProduct(product);
  }

  return (
    <div className={styles.ProductList_container}>
      <h2 className={styles.ProductList_title}>Product list</h2>

      <div className={styles.ProductList_header}>
        <span>Product name</span>
        <span>Quantity</span>
        <span>Price</span>
      </div>
      <div className={styles.ProductList_row}>
        <TextInput
          value={productFields.name}
          onChange={(name) => setProductFields({ ...productFields, name })}
        />
        <NumberInput
          value={productFields.quantity}
          onChange={(quantity) =>
            setProductFields({ ...productFields, quantity })
          }
        />
        <NumberInput
          value={productFields.price}
          onChange={(price) => setProductFields({ ...productFields, price })}
        />

        <NormalButton
          className={styles.ProductList_addButton}
          onClick={handleClick}
          type="button"
        >
          <AddIcon />
        </NormalButton>
      </div>
      <div className={styles.ProductList_body}>
        <AnimatePresence>
          {products.length === 0 ? (
            <motion.span
              layout
              transition={{ type: "spring", bounce: 0, duration: 0.4 }}
              initial={{ left: "-20%", opacity: 0 }}
              animate={{ left: 0, opacity: 1 }}
              exit={{ left: "40%", opacity: 0 }}
              className={styles.ProductList_noProducts}
            >
              No products
            </motion.span>
          ) : (
            products.map((product) => ListItem(product))
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
