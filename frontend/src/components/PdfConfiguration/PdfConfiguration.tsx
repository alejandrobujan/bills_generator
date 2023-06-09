import {
  currencyMap,
  fontSizeMap,
  fontStyleMap,
  languageMap,
  paperSizeMap,
} from "../../entities/ConfigSchemas";
import PdfConfig from "../../entities/PdfConfig";
import {} from "../../entities/PdfConfigDto";
import CheckboxInput from "../Input/CheckboxInput";
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
          label="Currency"
          value={config.currency}
          onChange={(currency) => {
            onChangeConfig({
              ...config,
              currency: currencyMap.get(currency)!,
            });
          }}
        >
          <option value="euro">Euro</option>
          <option value="dollar">Dollar</option>
        </SelectInput>

        <SelectInput
          label="Language"
          value={config.language}
          onChange={(language) => {
            onChangeConfig({
              ...config,
              language: languageMap.get(language)!,
            });
          }}
        >
          <option value="en">English</option>
          <option value="es">Spanish</option>
          <option value="gl">Galician</option>
        </SelectInput>

        <SelectInput
          label="Font style"
          value={config.fontStyle}
          onChange={(type) => {
            onChangeConfig({
              ...config,
              fontStyle: fontStyleMap.get(type)!,
            });
          }}
        >
          <option value="latex">Latex (Default)</option>
          <option value="times">Times New Roman</option>
        </SelectInput>

        <SelectInput
          label="Font size"
          value={config.fontSize.toString()}
          onChange={(fontSizeStr) =>
            onChangeConfig({
              ...config,
              fontSize: fontSizeMap.get(fontSizeStr)!,
            })
          }
        >
          <option value="10">10</option>
          <option value="11">11</option>
          <option value="12">12</option>
        </SelectInput>

        <SelectInput
          label="Paper size"
          value={config.paperSize}
          onChange={(paper) => {
            onChangeConfig({
              ...config,
              paperSize: paperSizeMap.get(paper)!,
            });
          }}
        >
          <option value="a4paper">A4</option>
          <option value="a5paper">A5</option>
          <option value="b5paper">B5</option>
          <option value="executivepaper">Executive</option>
          <option value="legalpaper">Legal</option>
          <option value="letterpaper">Letter</option>
        </SelectInput>

        <CheckboxInput
          label="Landscape"
          checked={config.landscape}
          onChange={(landscape) => {
            onChangeConfig({
              ...config,
              landscape,
            });
          }}
        />
      </div>
    </div>
  );
}
