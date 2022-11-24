import Button from "./Button";
import styles from "./button.module.scss";

interface Props {
  children: React.ReactNode;
  type?: "button" | "submit" | "reset";
  className?: string;
}

export default function AcceptButton({ children, type, className }: Props) {
  return (
    <Button type={type} className={`${className} ${styles.AcceptButton}`}>
      {children}
    </Button>
  );
}
