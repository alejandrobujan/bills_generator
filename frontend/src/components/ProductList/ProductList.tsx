import Product from "../../entities/Product";
import styles from "./productList.module.scss";

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
  return (
    <div className={styles.ProductList_container}>
      <div className={styles.ProductList_header}>
        <span>Product</span>
        <span>Quantity</span>
        <span>Price</span>
        <span>Total</span>
      </div>
      <div className={styles.ProductList_body}>
        {products.map((product) => ListItem(product))}
      </div>
    </div>
  );
}
