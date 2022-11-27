import styles from "./importFile.module.scss";
import { ChangeEvent } from "react";
import AcceptButton from "../Buttton/AcceptButton";
import CloudUploadIcon from "@mui/icons-material/CloudUpload";

interface Props {
  className?: string;
  onImportFile: (file: File | undefined) => void;
}

export default function ImportFile({ className, onImportFile }: Props) {
  function handleChange(e: ChangeEvent<HTMLInputElement>) {
    onImportFile(e.target.files?.[0]);
  }

  return (
    <div className={`${className} ${styles.ImportFile_container}`}>
      <label
        className={styles.ImportFile_uploadLabel}
        htmlFor="file-upload"
      >
        <AcceptButton>
          <span>Import file</span>
          <CloudUploadIcon />
        </AcceptButton>
      </label>
      <input
        onChange={handleChange}
        type="file"
        id="file-upload"
        accept="application/json"
      />
    </div>
  );
}
