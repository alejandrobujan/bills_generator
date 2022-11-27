import { MouseEvent, useState } from "react";
import Product, { ProductSchema } from "../../entities/Product";
import NormalButton from "../Buttton/NormalButton";
import NumberInput from "../Input/NumberInput";
import TextInput from "../Input/TextInput";
import styles from "./productList.module.scss";
import AddIcon from "@mui/icons-material/Add";
import DeleteIcon from "@mui/icons-material/DeleteOutline";
import { useNotifications } from "../NotificationManager/NotificationManager";
import { AnimatePresence, motion } from "framer-motion";
import { v4 } from "uuid";
import { ValidationError } from "runtypes";
import Utils from "../../utils/utils";

interface Props {
  products: Product[];
  onAddProduct: (product: Product) => void;
  onRemoveProduct: (product: Product["id"]) => void;
}

interface ItemProps {
  product: Product;
  onRemoveProduct: (product: Product["id"]) => void;
}

function ListItem({ product, onRemoveProduct }: ItemProps) {
  return (
    <motion.div
      layout
      transition={{ type: "spring", bounce: 0, duration: 0.4 }}
      initial={{ left: "-20%", opacity: 0 }}
      animate={{ left: 0, opacity: 1 }}
      exit={{ left: "-20%", opacity: 0 }}
      className={styles.ProductList_item}
    >
      <div className={styles.ProductList_row}>
        <span>{product.name}</span>
        <span>{product.quantity} uds.</span>
        <span>{product.price}$</span>
      </div>
      <NormalButton
        className={styles.ProductList_removeButton}
        onClick={() => onRemoveProduct(product.id)}
        type="button"
      >
        <DeleteIcon />
      </NormalButton>
    </motion.div>
  );
}

export default function ProductList({
  products,
  onAddProduct,
  onRemoveProduct,
}: Props) {
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
    try {
      const product: Product = ProductSchema.check({
        ...productFields,
        id: v4(),
      });
      setProductFields(defaultProduct);
      onAddProduct(product);
    } catch (error: any) {
      const message = Utils.getValidationErrorMessage(error);
      createErrorNotification(`Invalid product: ${message}`, 8000);
    }
  }

  return (
    <div className={styles.ProductList_container}>
      <h2 className={styles.ProductList_title}>Product list</h2>

      <div className={styles.ProductList_row}>
        <span>Product name</span>
        <span>Quantity</span>
        <span>Price</span>
      </div>

      <div className={styles.ProductList_formWrapper}>
        <div className={styles.ProductList_row}>
          <TextInput
            ignoreEnter
            value={productFields.name}
            onChange={(name) => setProductFields({ ...productFields, name })}
          />
          <NumberInput
            ignoreEnter
            value={productFields.quantity}
            onChange={(quantity) =>
              setProductFields({ ...productFields, quantity })
            }
          />
          <NumberInput
            ignoreEnter
            value={productFields.price}
            onChange={(price) => setProductFields({ ...productFields, price })}
          />
        </div>

        <NormalButton
          className={styles.ProductList_addButton}
          onClick={handleClick}
          type="button"
        >
          <AddIcon />
        </NormalButton>
      </div>

      <AnimatePresence>
        {products.length === 0 ? (
          <motion.span
            layout
            transition={{ type: "spring", bounce: 0, duration: 0.4 }}
            initial={{ left: "-20%", opacity: 0 }}
            animate={{ left: 0, opacity: 1 }}
            exit={{ left: "-20%", opacity: 0 }}
            className={styles.ProductList_noProducts}
          >
            No products
          </motion.span>
        ) : (
          <div className={styles.ProductList_body}>
            <AnimatePresence>
              {products.map((product, index) => (
                <ListItem
                  key={index}
                  product={product}
                  onRemoveProduct={onRemoveProduct}
                />
              ))}
            </AnimatePresence>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
