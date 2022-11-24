import styles from "./billGenerator.module.scss";
import ArrowFwdIcon from "@mui/icons-material/ArrowForwardIos";
import AddIcon from "@mui/icons-material/Add";
import ImportFileSection from "../ImportFileSection/ImportFileSection";
import { FormEvent, useState } from "react";
import BillService from "../../services/BillService";
import NormalButton from "../Buttton/NormalButton";
import Bill from "../../entities/Bill";
import Product from "../../entities/Product";
import TextInput from "../Input/TextInput";
import ProductList from "../ProductList/ProductList";

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

  return (
    <form className={styles.BillGenerator_wrapper} onSubmit={handleSubmit}>
      {/* <ImportFileSection setSelectedFile={setSelectedFile} /> */}

      <div className={styles.BillGenerator_container}>
        <div className={styles.BillGenerator_billForm}>
          <TextInput
            label="User"
            value={formState.user}
            onChange={(user) => setFormState({ ...formState, user })}
          />
          <TextInput
            label="Seller"
            value={formState.seller}
            onChange={(seller) => setFormState({ ...formState, seller })}
          />
          <TextInput
            label="Purchaser"
            value={formState.purchaser}
            onChange={(purchaser) => setFormState({ ...formState, purchaser })}
          />

          <NormalButton>
            <span>Add Product</span>
            <AddIcon />
          </NormalButton>
        </div>

        <div className={styles.BillGenerator_separator} />

        <div className={styles.BillGenerator_productList}>
          <ProductList products={formState.products} />
        </div>
      </div>

      <label
        className={styles.BillGenerator_generateLabel}
        htmlFor="submit-bill"
      >
        <NormalButton>
          <span>Generate</span>
          <ArrowFwdIcon />
        </NormalButton>
      </label>
      <input type="submit" id="submit-bill" />
    </form>
  );
}
