import styles from "./billGenerator.module.scss";
import ArrowFwdIcon from "@mui/icons-material/ArrowForwardIos";
import LoopIcon from "@mui/icons-material/Loop";
import ImportFile from "../ImportFile/ImportFile";
import { FormEvent, useState } from "react";
import BillService from "../../services/BillService";
import NormalButton from "../Buttton/NormalButton";
import Bill from "../../entities/Bill";
import Product from "../../entities/Product";
import ProductList from "../ProductList/ProductList";
import TextInput from "../Input/TextInput";
import BillDto, { BillDtoSchema } from "../../entities/BillDto";
import { v4 } from "uuid";
import { useNotifications } from "../NotificationManager/NotificationManager";
import PdfConfiguration from "../PdfConfiguration/PdfConfiguration";
import PdfConfig, { getDefaultConfig } from "../../entities/PdfConfig";
import { AnimatePresence, motion } from "framer-motion";
import DownloadIcon from "@mui/icons-material/Download";
import AcceptButton from "../Buttton/AcceptButton";

export default function BillGenerator() {
  const { createErrorNotification, createSuccessNotification } =
    useNotifications();
  const [isBillGenerated, setIsBillGenerated] = useState<boolean>(false);
  const [billId, setBillId] = useState<Bill["id"] | undefined>(undefined);
  const [isGenerating, setIsGenerating] = useState<boolean>(false);
  const [formState, setFormState] = useState<{
    user: string;
    bill: {
      seller: string;
      purchaser: string;
      products: Product[];
    };
    config: PdfConfig;
  }>({
    user: "",
    bill: {
      seller: "",
      purchaser: "",
      products: [],
    },
    config: getDefaultConfig(),
  });

  function waitForBill(id: Bill["id"]) {
    BillService.getBill(id).then((bill) => {
      setIsGenerating(false);
      setIsBillGenerated(true);
      createSuccessNotification("Bill generated successfully", 5000);
    });
    //   if (bill) {
    //     setGeneratedBill(bill);
    //     setIsGenerating(false);
    //   }
    //   setTimeout(() => waitForBill(id), 500);
    // });
  }

  function handleImportFile(file: File | undefined) {
    if (!file) return;
    file.text().then((jsonString) => {
      try {
        const completeBill: BillDto = BillDtoSchema.check(
          JSON.parse(jsonString)
        );

        const productsWithId: Product[] = completeBill.bill.products.map(
          (product) => ({
            ...product,
            id: v4(),
          })
        );

        const newConfig = {
          ...getDefaultConfig(),
          ...completeBill.config,
        };

        setFormState({
          user: completeBill.user,
          bill: {
            ...formState.bill,
            seller: completeBill.bill.seller,
            purchaser: completeBill.bill.purchaser,
            products: productsWithId,
          },
          config: newConfig,
        });
      } catch (error: any) {
        createErrorNotification("Invalid bill specification", 8000);
        return;
      }
    });
  }

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (isGenerating) return;
    setIsGenerating(true);
    const billDto: BillDto = BillDtoSchema.check(formState);
    BillService.generateBill(billDto).then((id) => {
      setBillId(id);
      waitForBill(id);
    });
  }

  function handleAddProduct(product: Product) {
    setFormState({
      ...formState,
      bill: {
        ...formState.bill,
        products: [...formState.bill.products, product],
      },
    });
  }
  function handleRemoveProduct(id: Product["id"]) {
    setFormState({
      ...formState,
      bill: {
        ...formState.bill,
        products: formState.bill.products.filter((p) => p.id !== id),
      },
    });
  }

  function handleChangeConfig(config: PdfConfig) {
    setFormState({
      ...formState,
      config,
    });
  }

  return (
    <>
      <ImportFile
        className={styles.BillGenerator_importFile}
        onImportFile={(file) => handleImportFile(file)}
      />

      <form className={styles.BillGenerator_wrapper} onSubmit={handleSubmit}>
        <div className={styles.BillGenerator_generalForm}>
          <TextInput
            required
            label="User"
            value={formState.user}
            onChange={(user) => setFormState({ ...formState, user })}
          />
          <TextInput
            required
            label="Seller"
            value={formState.bill.seller}
            onChange={(seller) =>
              setFormState({
                ...formState,
                bill: { ...formState.bill, seller },
              })
            }
          />
          <TextInput
            required
            label="Purchaser"
            value={formState.bill.purchaser}
            onChange={(purchaser) =>
              setFormState({
                ...formState,
                bill: { ...formState.bill, purchaser },
              })
            }
          />
        </div>

        <div className={styles.BillGenerator_productList}>
          <ProductList
            products={formState.bill.products}
            onAddProduct={handleAddProduct}
            onRemoveProduct={handleRemoveProduct}
          />
        </div>

        <div className={styles.BillGenerator_pdfConfiguration}>
          <PdfConfiguration
            config={formState.config}
            onChangeConfig={handleChangeConfig}
          />
        </div>

        <AnimatePresence>
          {isBillGenerated ? (
            <motion.a
              href={`/api/bills/${billId}`}
              download="bill.pdf"
              target="_blank"
              rel="noreferrer"
            >
              <AcceptButton type="button">
                <span>Download generated bill</span>
                <DownloadIcon />
              </AcceptButton>
            </motion.a>
          ) : (
            <NormalButton
              type="submit"
              className={styles.BillGenerator_generateButton}
            >
              <span>Generate</span>

              <AnimatePresence>
                {isGenerating ? (
                  <motion.div
                    transition={{ duration: 0.6 }}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    className={styles.BillGenerator_loadingLoop}
                  >
                    <LoopIcon />
                  </motion.div>
                ) : (
                  <motion.div
                    transition={{ duration: 0.8 }}
                    initial={{ left: 0, opacity: 0 }}
                    animate={{ left: 0, opacity: 1 }}
                    exit={{ left: "100%" }}
                  >
                    <ArrowFwdIcon />
                  </motion.div>
                )}
              </AnimatePresence>
            </NormalButton>
          )}
        </AnimatePresence>
      </form>
    </>
  );
}
