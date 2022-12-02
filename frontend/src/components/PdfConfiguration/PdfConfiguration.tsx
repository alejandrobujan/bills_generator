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
          label="Font style"
          value={config.font_style}
          onChange={(type) => {
            let constType;
            if (type === "latex") constType = "latex" as const;
            else if (type === "times")
              constType = "times" as const;

            onChangeConfig({
              ...config,
              font_style: constType,
            });
          }}
        >
          <option value="latex">latex</option>
          <option value="times">times</option>
        </SelectInput>

        <NumberInput
          label="Font size"
          value={config.font_size}
          onChange={(size) =>
            onChangeConfig({
              ...config,
              font_size: size,
            })
          }
        />
      </div>
    </div>
  );
}
