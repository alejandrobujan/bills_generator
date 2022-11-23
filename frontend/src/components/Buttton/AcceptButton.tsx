import Button from "./Button";
import styles from "./button.module.scss";

interface Props {
  children: React.ReactNode;
}

export default function AcceptButton({ children }: Props) {
  return <Button className={styles.AcceptButton}>{children}</Button>;
}
