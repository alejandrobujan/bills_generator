import { ChangeEvent, useState } from "react";
import styles from "./input.module.scss";

interface Props {
  label?: string;
  placeholder?: string;
  value?: any;
  type: "text" | "number" | "checkbox";
  required?: boolean;
  checked?: boolean;
  onChange: (e: ChangeEvent<HTMLInputElement>) => void;
  ignoreEnter?: boolean;
}

export default function Input({
  label,
  placeholder,
  value,
  type,
  onChange,
  checked,
  required = false,
  ignoreEnter = false,
}: Props) {
  const [isSelected, setIsSelected] = useState(false);

  return (
    <div className={styles.Input_wrapper} data-is_selected={isSelected}>
      <label className={styles.Input_label}>{label}</label>
      <input
        onKeyDown={(e) => {
          if (e.key === "Enter" && ignoreEnter) e.preventDefault();
        }}
        checked={checked}
        required={required}
        className={styles.Input_input}
        type={type}
        placeholder={placeholder}
        value={value}
        onChange={onChange}
        onFocus={() => setIsSelected(true)}
        onBlur={() => setIsSelected(false)}
      />
    </div>
  );
}
