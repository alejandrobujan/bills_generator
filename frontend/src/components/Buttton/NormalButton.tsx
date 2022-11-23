import Button from "./Button";
import styles from "./button.module.scss";

interface Props {
  children: React.ReactNode;
}

export default function NornalButton({ children }: Props) {
  return <Button className={styles.NormalButton}>{children}</Button>;
}
