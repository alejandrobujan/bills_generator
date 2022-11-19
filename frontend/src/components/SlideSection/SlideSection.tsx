import AnimatePresence from "framer-motion";
import styles from "./slideSection.module.scss";

interface Props {
  titles: string[];
  children: JSX.Element[];
}

export default function SlideSection({ children }: Props): JSX.Element {
  return (
    <div className={styles.SlideSection_container}>
      <AnimatePresence>
			</AnimatePresence>
    </div>
  );
}
