import styles from "./billGenerator.module.scss";
import ArrowFwdIcon from "@mui/icons-material/ArrowForwardIos";
import ImportFileSection from "../ImportFileSection/ImportFileSection";
import { FormEvent, useState } from "react";
import BillService from "../../services/BillService";
import NormalButton from "../Buttton/NormalButton";
import Bill from "../../entities/Bill";
import Product from "../../entities/Product";
import ProductList from "../ProductList/ProductList";
import TextInput from "../Input/TextInput";

export default function BillGenerator() {
  const [selectedFile, setSelectedFile] = useState<File | undefined>(undefined);
  const [generatedBill, setGeneratedBill] = useState<Blob | undefined>(
    undefined
  );
  const [isGenerating, setIsGenerating] = useState<boolean>(false);
  const [formState, setFormState] = useState<{
    user: string;
    seller: string;
    purchaser: string;
    products: Product[];
  }>({
    user: "",
    seller: "",
    purchaser: "",
    products: [],
  });

  function waitForBill(id: Bill["id"]) {
    BillService.getBill(id).then((bill) => {
      if (bill) {
        setGeneratedBill(bill);
        setIsGenerating(false);
      }
      setTimeout(() => waitForBill(id), 500);
    });
  }

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setIsGenerating(true);
    // BillService.generateBill(selectedFile).then((id) => waitForBill(id));
  }

  function handleAddProduct(product: Product) {
    setFormState({
      ...formState,
      products: [...formState.products, product],
    });
  }

  function handleRemoveProduct(id: Product["id"]) {
  }

  return (
    <form className={styles.BillGenerator_wrapper} onSubmit={handleSubmit}>
      {/* <ImportFileSection setSelectedFile={setSelectedFile} /> */}

      <div className={styles.BillGenerator_generalForm}>
        <TextInput
          required
          label="User"
          value={formState.user}
          onChange={(user) => setFormState({ ...formState, user })}
        />
        <TextInput
          required
          label="Seller"
          value={formState.seller}
          onChange={(seller) => setFormState({ ...formState, seller })}
        />
        <TextInput
          required
          label="Purchaser"
          value={formState.purchaser}
          onChange={(purchaser) => setFormState({ ...formState, purchaser })}
        />
      </div>

      <div className={styles.BillGenerator_productList}>
        <ProductList
          products={formState.products}
          onAddProduct={handleAddProduct}
          onRemoveProduct={handleRemoveProduct}
        />
      </div>

      <NormalButton type="submit" className={styles.BillGenerator_generateButton}>
        <span>Generate</span>
        <ArrowFwdIcon />
      </NormalButton>
    </form>
  );
}
