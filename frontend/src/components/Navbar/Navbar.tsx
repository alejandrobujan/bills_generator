import styles from "./navbar.module.scss";
import DescriptionIcon from "@mui/icons-material/Description";

export default function Navbar() {
  return (
    <nav className={styles.Navbar_container}>
      <div className={styles.Navbar_title}>
        <DescriptionIcon />
        <span>Bill generator</span>
      </div>
    </nav>
  );
}
