import { useState } from "react";
import styles from "./input.module.scss";

interface Props {
  label: string;
  placeholder?: string;
  value?: string;
  onChange: (value: string) => void;
}

export default function TextInput({
  label,
  placeholder,
  value,
  onChange,
}: Props) {
  const [isSelected, setIsSelected] = useState(false);


  return (
    <div className={styles.Input_wrapper} data-is_selected={isSelected}>
      <label className={styles.Input_label} htmlFor={label}>
        {label}
      </label>
      <input
        className={styles.Input_input}
        type="text"
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onFocus={() => setIsSelected(true)}
        onBlur={() => setIsSelected(false)}
      />
    </div>
  );
}
