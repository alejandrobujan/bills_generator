import { ButtonProps } from "../../utils/defaultIntefaces";
import Button from "./Button";
import styles from "./button.module.scss";

export default function DangerButton({ children, className, ...props }: ButtonProps) {
  return (
    <Button className={`${className} ${styles.DangerButton}`} {...props}>
      {children}
    </Button>
  );
}
