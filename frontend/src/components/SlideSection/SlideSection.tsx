import styles from "./slideSection.module.scss";
import BillGenerator from "../BillGenerator/BillGenerator";

interface Props {
  titles: string[];
  children: JSX.Element[];
}

export default function SlideSection({ children }: Props): JSX.Element {
  return (
    <div className={styles.SlideSection_container}>
      <BillGenerator />
    </div>
  );
}
