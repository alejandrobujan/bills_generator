import { AnimatePresence, motion } from "framer-motion";
import { FormEvent, useState } from "react";
import BillDto from "../../entities/BillDto";
import BillService from "../../services/BillService";
import NormalButton from "../Buttton/NormalButton";
import TextInput from "../Input/TextInput";
import { useNotifications } from "../NotificationManager/NotificationManager";
import SearchIcon from "@mui/icons-material/Search";
import styles from "./billList.module.scss";
import BillDescription from "../../entities/BillDescription";
import DownloadIcon from "@mui/icons-material/Download";

interface ItemProps {
  bill: BillDescription;
}

function BillItem({ bill }: ItemProps) {
  return (
    <motion.div
      transition={{ duration: 0.2 }}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      className={styles.BillList_item}
    >
      <span className={styles.billItemTitle}>{bill.title}</span>
      <span className={styles.billItemDescription}>
        {/* Format date to hh:mm dd/mm/yy */}
        {bill.createdAt.toLocaleString("es-ES", {
          hour: "2-digit",
          minute: "2-digit",
          day: "2-digit",
          month: "2-digit",
          year: "2-digit",
        })}
      </span>
      <a
        href={`/api/bills/${bill.id}/download`}
        download={`bill-${bill.id}.pdf`}
        target="_blank"
        rel="noreferrer"
        className={styles.BillList_downloadButton}
      >
        <NormalButton type="button">
          <span>Download</span>
          <DownloadIcon />
        </NormalButton>
      </a>
    </motion.div>
  );
}

export default function BillList() {
  const { createErrorNotification } = useNotifications();

  const [currentUser, setCurrentUser] = useState<BillDto["user"] | undefined>(
    undefined
  );
  const [isCurrentUser, setIsCurrentUser] = useState<boolean>(false);
  const [bills, setBills] = useState<BillDescription[]>([]);

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!currentUser) return;
    BillService.getBills(currentUser)
      .then((bills) => {
        setIsCurrentUser(true);
        setBills(bills);
      })
      .catch(() => createErrorNotification("Error while fetching bills", 8000));
  }

  return (
    <div className={styles.BillList_container}>
      <form onSubmit={handleSubmit} className={styles.BillList_userForm}>
        <TextInput label="User" onChange={(user) => setCurrentUser(user)} />
        <NormalButton type="submit">
          <span>Search bills</span>
          <SearchIcon />
        </NormalButton>
      </form>

      {isCurrentUser && (
        <>
          <h2 className={styles.BillList_title}>Bill List</h2>

          <AnimatePresence>
            {bills.length === 0 ? (
              <motion.span
                layout
                transition={{ type: "spring", bounce: 0, duration: 0.4 }}
                initial={{ left: "-20%", opacity: 0 }}
                animate={{ left: 0, opacity: 1 }}
                exit={{ left: "-20%", opacity: 0 }}
                className={styles.BillList_noBills}
              >
                No bills
              </motion.span>
            ) : (
              <div className={styles.BillList_list}>
                <AnimatePresence>
                  {bills.map((bill, idx) => (
                    <BillItem key={idx} bill={bill} />
                  ))}
                </AnimatePresence>
              </div>
            )}
          </AnimatePresence>
        </>
      )}
    </div>
  );
}
