import { motion } from "framer-motion";
import Head from "next/head";
import { useState } from "react";
import BillGenerator from "../components/BillGenerator/BillGenerator";
import BillList from "../components/BillList/BillList";
import NotificationManager from "../components/NotificationManager/NotificationManager";
import WaveSvg from "../components/WaveSvg/WaveSvg";
import styles from "./styles/home.module.scss";

const slideAnimation = {
  transition: { duration: 0.3 },
  right: {
    variants: {
      visible: { left: 0 },
      hidden: { left: "100%" },
    },
  },
  left: {
    variants: {
      visible: { left: 0 },
      hidden: { left: "-100%" },
    },
  },
};

export default function Home() {
  const [seeBillsSelected, setSeeBillsSelected] = useState(false);

  return (
    <>
      <Head>
        <title>Bill generator</title>
        <meta
          name="description"
          content="A site where you can generate high quality and customizable bills in a simple way"
        />
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>

      <NotificationManager>
        <div className={styles.Home_container}>
          <div className={styles.Home_titleContainer}>
            <div className={styles.Home_waveContainer}>
              <WaveSvg />
            </div>
            <h1 className={styles.Home_title}>Bill generator</h1>
          </div>

          <div className={styles.Home_slideSelectorContainer}>
            <div
              className={styles.Home_slideSectionTitle}
              onClick={() => setSeeBillsSelected(false)}
            >
              <span data-is_selected={!seeBillsSelected}>Generate bill</span>
              <motion.div
                transition={slideAnimation.transition}
                animate={!seeBillsSelected ? "visible" : "hidden"}
                variants={slideAnimation.right.variants}
                className={styles.Home_slideSectionLine}
              />
            </div>
            <div
              className={styles.Home_slideSectionTitle}
              onClick={() => setSeeBillsSelected(true)}
            >
              <span data-is_selected={seeBillsSelected}>See bills</span>
              <motion.div
                transition={slideAnimation.transition}
                animate={seeBillsSelected ? "visible" : "hidden"}
                variants={slideAnimation.left.variants}
                className={styles.Home_slideSectionLine}
              />
            </div>
          </div>

          <motion.div
            transition={slideAnimation.transition}
            animate={!seeBillsSelected ? "visible" : "hidden"}
            variants={slideAnimation.left.variants}
            className={styles.Home_slideContentWrapper}
          >
            <div className={styles.Home_slideSectionContent}>
              <BillGenerator />
            </div>
            <div className={styles.Home_slideSectionContent}>
              <BillList />
            </div>
          </motion.div>
        </div>
      </NotificationManager>
    </>
  );
}
