import styles from "./importFileSection.module.scss";
import CloudUploadIcon from "@mui/icons-material/CloudUpload";
import { ChangeEvent } from "react";

interface Props {
  setSelectedFile: (file: File | undefined) => void;
}

export default function ImportFileSection({ setSelectedFile }: Props) {
  function handleChange(e: ChangeEvent<HTMLInputElement>) {
    console.log(e.target.files?.[0]);
    setSelectedFile(e.target.files?.[0]);
  }

  return (
    <div className={styles.ImportFileSection_container}>
      <div className={styles.ImportFileSection_title}>
        <span>
          Drop a Json file here
          <br />
          or
        </span>
      </div>

      <label className={styles.ImportFileSection_fileBtn} htmlFor="file-upload">
        <span>Choose file</span>
        <CloudUploadIcon />
      </label>
      <input
        onChange={handleChange}
        className={styles.ImportFileSection_fileBtn}
        type="file"
        id="file-upload"
        accept="application/json"
      />
    </div>
  );
}
