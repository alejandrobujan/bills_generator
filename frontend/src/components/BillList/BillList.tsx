import { AnimatePresence, motion } from "framer-motion";
import { FormEvent, useState } from "react";
import BillDescription from "../../entities/BillDescription";
import BillDto from "../../entities/BillDto";
import BillService from "../../services/BillService";
import NormalButton from "../Buttton/NormalButton";
import TextInput from "../Input/TextInput";
import { useNotifications } from "../NotificationManager/NotificationManager";
import SearchIcon from "@mui/icons-material/Search";
import styles from "./billList.module.scss";

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
      className={styles.billItem}
    >
      <div className={styles.billItemTitle}>{bill.title}</div>
      <div className={styles.billItemDescription}>
        {bill.timestamp.toISOString()}
      </div>
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
