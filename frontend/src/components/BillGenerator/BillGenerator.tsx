import styles from "./billGenerator.module.scss";
import ArrowFwd from "@mui/icons-material/ArrowForwardIos";
import ImportFileSection from "../ImportFileSection/ImportFileSection";
import { FormEvent, useState } from "react";
import BillService from "../../services/BillService";
import NormalButton from "../Buttton/NormalButton";

export default function BillGenerator() {
  const [selectedFile, setSelectedFile] = useState<File | undefined>(undefined);
  const [generatedBill, setGeneratedBill] = useState<Blob | undefined>(
    undefined
  );

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    // BillService.generateBill(selectedFile).then((blob) =>
    //   setGeneratedBill(blob)
    // );
  }

  return (
    <form className={styles.BillGenerator_container} onSubmit={handleSubmit}>
      <ImportFileSection setSelectedFile={setSelectedFile} />
      <label
        className={styles.BillGenerator_generateLabel}
        htmlFor="submit-bill"
      >
        <NormalButton>
          <span>Generate</span>
          <ArrowFwd />
        </NormalButton>
      </label>
      <input type="submit" id="submit-bill" />
    </form>
  );
}
