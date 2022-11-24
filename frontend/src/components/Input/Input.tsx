import { useState } from "react";
import styles from "./input.module.scss";

interface Props {
  label?: string;
  placeholder?: string;
  value?: any;
	type: "text" | "number";
	required?: boolean;
  onChange: (value: string) => void;
}

export default function Input({
  label,
  placeholder,
  value,
	type,
  onChange,
	required = false
}: Props) {
  const [isSelected, setIsSelected] = useState(false);

  return (
    <div className={styles.Input_wrapper} data-is_selected={isSelected}>
      <label className={styles.Input_label}>{label}</label>
      <input
				required={required}
        className={styles.Input_input}
        type={type}
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onFocus={() => setIsSelected(true)}
        onBlur={() => setIsSelected(false)}
      />
    </div>
  );
}
