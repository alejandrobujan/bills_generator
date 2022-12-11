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
import Utils from "../../utils/utils";
import ProductDto, {
  getDefaultProductDto,
  toProduct,
} from "../../entities/ProductDto";

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
        <span>{product.quantity}</span>
        <span>{product.price}€</span>
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

  const [currentProduct, setCurrentProduct] = useState<ProductDto>(
    getDefaultProductDto()
  );

  function handleClick(_: MouseEvent<HTMLButtonElement>) {
    try {
      const product: Product = ProductSchema.parse(toProduct(currentProduct));
      setCurrentProduct(getDefaultProductDto());
      onAddProduct(product);
    } catch (error: any) {
      const message = Utils.getZodErrorMessages(error);
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
            value={currentProduct.name}
            onChange={(name) => setCurrentProduct({ ...currentProduct, name })}
          />
          <NumberInput
            ignoreEnter
            value={currentProduct.quantity}
            onChange={(quantity) =>
              setCurrentProduct({ ...currentProduct, quantity })
            }
          />
          <NumberInput
            ignoreEnter
            value={currentProduct.price}
            onChange={(price) =>
              setCurrentProduct({ ...currentProduct, price })
            }
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
