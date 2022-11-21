import styles from "./billGenerator.module.scss";
import ArrowFwd from "@mui/icons-material/ArrowForwardIos";
import ImportFileSection from "./ImportFileSection";
import { FormEvent, useState } from "react";
import BillService from "../../services/BillService";

export default function BillGenerator() {
  const [selectedFile, setSelectedFile] = useState<File | undefined>(undefined);
  const [generatedBill, setGeneratedBill] = useState<Blob | undefined>(
    undefined
  );

  function handleSubmit(e: FormEvent<HTMLInputElement>) {
    e.preventDefault();
    BillService.generateBill(selectedFile).then((blob) =>
      setGeneratedBill(blob)
    );
  }

  return (
    <div className={styles.BillGenerator_container}>
      <h1 className={styles.BillGenerator_title}>Generate</h1>

      <form>
        <ImportFileSection setSelectedFile={setSelectedFile} />
        <label
          className={styles.BillGenerator_generateBtn}
          htmlFor="submit-bill"
        >
          <span>Generate</span>
          <ArrowFwd />
        </label>
        <input type="submit" id="submit-bill" onSubmit={handleSubmit} />
      </form>
    </div>
  );
}
