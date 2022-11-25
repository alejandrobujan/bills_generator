import { ButtonProps } from "../../utils/defaultIntefaces";
import Button from "./Button";
import styles from "./button.module.scss";

export default function NornalButton({ children, className, ...props }: ButtonProps) {
  return (
    <Button className={`${className} ${styles.NormalButton}`} {...props}>
      {children}
    </Button>
  );
}
