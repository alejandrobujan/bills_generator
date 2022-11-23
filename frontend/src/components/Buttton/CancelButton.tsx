import Button from "./Button";
import styles from "./button.module.scss";

interface Props {
  children: React.ReactNode;
}

export default function CancelButton({ children }: Props) {
  return <Button className={styles.CancelButton}>{children}</Button>;
}
