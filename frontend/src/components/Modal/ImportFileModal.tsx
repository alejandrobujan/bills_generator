import styles from "./modal.module.scss";
import CloseIcon from "@mui/icons-material/Close";
import CheckIcon from "@mui/icons-material/Check";
import { motion } from "framer-motion";
import ImportFileSection from "../ImportFile/ImportFile";
import { useState } from "react";
import NormalButton from "../Buttton/NormalButton";

interface Props {
  onAccept: (file: File | undefined) => void;
  onClose: () => void;
}

export default function ImportFileModal({
  onAccept,
  onClose,
}: Props): JSX.Element {
  const [importedFile, setImportedFile] = useState<File | undefined>(undefined);

  return (
    <motion.div
      transition={{ duration: 0.3 }}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className={styles.Modal_overlay}
      onClick={onClose}
    >
      <motion.div
        transition={{ duration: 0.3 }}
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        exit={{ scale: 0 }}
        className={styles.Modal_container}
        onClick={(e) => e.stopPropagation()}
      >
        <CloseIcon onClick={onClose} className={styles.Modal_closeIcon} />

        <h1 className={styles.Modal_title}>
          <span>Import Json file</span>
        </h1>

        <ImportFileSection onImportFile={(file) => setImportedFile(file)} />

        <div className={styles.Modal_buttonsContainer}>
          <NormalButton onClick={() => onAccept(importedFile)}>
            <span>Accept</span>
            <CheckIcon />
          </NormalButton>
        </div>
      </motion.div>
    </motion.div>
  );
}
