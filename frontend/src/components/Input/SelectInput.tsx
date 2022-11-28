import { useState } from "react";
import styles from "./input.module.scss";

interface Props {
  label?: string;
  value?: string;
  required?: boolean;
  onChange: (value: string) => void;
  children: React.ReactNode;
}

export default function TextInput({
  label,
  value,
  onChange,
  children,
  required = false,
}: Props) {
  const [isSelected, setIsSelected] = useState(false);

  return (
    <div className={styles.Input_wrapper} data-is_selected={isSelected}>
      <label className={styles.Input_label}>{label}</label>
      <select
				className={styles.Input_select}
        value={value}
        required={required}
        onChange={(e) => onChange(e.target.value)}
        onFocus={() => setIsSelected(true)}
        onBlur={() => setIsSelected(false)}
      >
        {children}
      </select>
    </div>
  );
}
