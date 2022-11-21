import DescriptionIcon from "@mui/icons-material/Description";
import SeeIcon from "@mui/icons-material/FindInPage";
import GenerateIcon from "@mui/icons-material/DocumentScanner";
import styles from "./leftSection.module.scss";
import { useState } from "react";

export default function LeftSection() {
  const [generateSelected, setGenerateSelected] = useState(true);

  return (
    <div className={styles.LeftSection_container}>
      <div className={styles.LeftSection_title}>
        {/* <DescriptionIcon className={styles.LeftSection_titleIcon} /> */}
        <h1>Bill Generator</h1>
      </div>

      <div className={styles.LeftSection_menu}>
        <div
          className={styles.LeftSection_item}
          data-is_selected={generateSelected}
          onClick={() => setGenerateSelected(true)}
        >
          <GenerateIcon />
          <span>Generate bills</span>
        </div>
        <div
          className={styles.LeftSection_item}
          data-is_selected={!generateSelected}
          onClick={() => setGenerateSelected(false)}
        >
          <SeeIcon />
          <span>See bills</span>
        </div>
      </div>
    </div>
  );
}
