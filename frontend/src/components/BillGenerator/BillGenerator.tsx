import styles from "./billGenerator.module.scss";
import ArrowFwdIcon from "@mui/icons-material/ArrowForwardIos";
import LoopIcon from "@mui/icons-material/Loop";
import ImportFile from "../ImportFile/ImportFile";
import { FormEvent, useEffect, useState } from "react";
import BillService from "../../services/BillService";
import NormalButton from "../Buttton/NormalButton";
import BillRequest, {
  getDefaultBillRequest,
  toBillRequestDto,
} from "../../entities/BillRequest";
import Product from "../../entities/Product";
import ProductList from "../ProductList/ProductList";
import TextInput from "../Input/TextInput";
import BillRequestDto, {
  BillRequestDtoSchema,
  toBillRequest,
} from "../../entities/BillRequestDto";
import { useNotifications } from "../NotificationManager/NotificationManager";
import PdfConfiguration from "../PdfConfiguration/PdfConfiguration";
import PdfConfig from "../../entities/PdfConfig";
import { AnimatePresence, motion } from "framer-motion";
import DownloadIcon from "@mui/icons-material/Download";
import AcceptButton from "../Buttton/AcceptButton";

export default function BillGenerator() {
  const { createErrorNotification, createSuccessNotification } =
    useNotifications();

  const [isGenerating, setIsGenerating] = useState<boolean>(false);
  const [billId, setBillId] = useState<number | undefined>(undefined);
  const [billRequest, setBillRequest] = useState<BillRequest>(
    getDefaultBillRequest()
  );

  function waitForBill(id: number) {
    BillService.getBill(id)
      .then((bill) => {
        if (bill.error) {
          setIsGenerating(false);
          createErrorNotification(bill.errorMessage, 5000);
          return;
        }
        if (!bill.isAvailable) {
          setTimeout(() => waitForBill(id), 500);
          return;
        }
        createSuccessNotification("Bill generated successfully", 5000);
        setBillId(id);
        setIsGenerating(false);
      })
      .catch(() => {
        setIsGenerating(false);
        setBillId(undefined);
        createErrorNotification("Error generating bill", 5000);
      });
  }

  function handleImportFile(file: File | undefined) {
    if (!file) return;
    file
      .text()
      .then((jsonString) => {
        try {
          const billDto: BillRequestDto = BillRequestDtoSchema.check(
            JSON.parse(jsonString)
          );
          setBillRequest(toBillRequest(billDto));
        } catch (error: any) {
          createErrorNotification("Invalid bill specification", 8000);
          return;
        }
      })
      .catch(() => createErrorNotification("Error while importing file", 8000));
  }

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (isGenerating) return;
    setIsGenerating(true);

    BillService.generateBill(toBillRequestDto(billRequest))
      .then((id) => setTimeout(() => waitForBill(id), 500))
      .catch(() => {
        setIsGenerating(false);
        createErrorNotification("Error while generating bill", 5000);
      });
  }

  function handleAddProduct(product: Product) {
    setBillRequest({
      ...billRequest,
      bill: {
        ...billRequest.bill,
        products: [...billRequest.bill.products, product],
      },
    });
  }
  function handleRemoveProduct(id: Product["id"]) {
    setBillRequest({
      ...billRequest,
      bill: {
        ...billRequest.bill,
        products: billRequest.bill.products.filter((p) => p.id !== id),
      },
    });
  }

  function handleChangeConfig(config: PdfConfig) {
    setBillRequest({
      ...billRequest,
      config,
    });
  }

  useEffect(() => {
    setBillId(undefined);
  }, [billRequest]);

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
            value={billRequest.user}
            onChange={(user) => setBillRequest({ ...billRequest, user })}
          />
          <TextInput
            required
            label="Title"
            value={billRequest.bill.title}
            onChange={(title) =>
              setBillRequest({
                ...billRequest,
                bill: { ...billRequest.bill, title },
              })
            }
          />
          <TextInput
            required
            label="Seller"
            value={billRequest.bill.seller}
            onChange={(seller) =>
              setBillRequest({
                ...billRequest,
                bill: { ...billRequest.bill, seller },
              })
            }
          />
          <TextInput
            required
            label="Purchaser"
            value={billRequest.bill.purchaser}
            onChange={(purchaser) =>
              setBillRequest({
                ...billRequest,
                bill: { ...billRequest.bill, purchaser },
              })
            }
          />
        </div>

        <div className={styles.BillGenerator_productList}>
          <ProductList
            products={billRequest.bill.products}
            onAddProduct={handleAddProduct}
            onRemoveProduct={handleRemoveProduct}
          />
        </div>

        <div className={styles.BillGenerator_pdfConfiguration}>
          <PdfConfiguration
            config={billRequest.config}
            onChangeConfig={handleChangeConfig}
          />
        </div>

        <AnimatePresence>
          {billId ? (
            <motion.a
              href={`/api/bills/${billId}/download`}
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
                    layout
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
                    layout
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
