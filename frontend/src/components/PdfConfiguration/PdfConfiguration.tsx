import { useState } from "react";
import PdfConfig from "../../entities/PdfConfig";
import NumberInput from "../Input/NumberInput";
import SelectInput from "../Input/SelectInput";
import styles from "./pdfConfiguration.module.scss";

interface Props {
  config: PdfConfig;
  onChangeConfig: (config: PdfConfig) => void;
}

export default function PdfConfiguration({ config, onChangeConfig }: Props) {
  return (
    <div className={styles.PdfConfiguration_container}>
      <h2 className={styles.PdfConfiguration_title}>Configuration</h2>

      <div className={styles.PdfConfiguration_form}>
        <SelectInput
          label="Font family"
          value={config.fontFamily}
          onChange={(type) => {
            let constType;
            if (type === "Arial") constType = "Arial" as const;
            else if (type === "Times New Roman")
              constType = "Times New Roman" as const;
            else if (type === "Courier New") constType = "Courier New" as const;

            onChangeConfig({
              ...config,
              fontFamily: constType,
            });
          }}
        >
          <option value="Arial">Arial</option>
          <option value="Times New Roman">Times New Roman</option>
          <option value="Courier New">Courier New</option>
        </SelectInput>

        <NumberInput
          label="Font size"
          value={config.fontSize}
          onChange={(size) =>
            onChangeConfig({
              ...config,
              fontSize: size,
            })
          }
        />
      </div>
    </div>
  );
}
