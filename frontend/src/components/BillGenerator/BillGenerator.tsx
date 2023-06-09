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
import ExportIcon from "@mui/icons-material/IosShare";
import Utils from "../../utils/utils";
import NumberInput from "../Input/NumberInput";

export default function BillGenerator() {
  const { createErrorNotification, createSuccessNotification } =
    useNotifications();

  const [isGenerating, setIsGenerating] = useState<boolean>(false);
  const [billId, setBillId] = useState<number | undefined>(undefined);
  const [billRequest, setBillRequest] = useState<BillRequest>(
    getDefaultBillRequest()
  );

  function handleImportFile(file: File | undefined) {
    if (!file) return;
    file
      .text()
      .then((jsonString) => {
        try {
          const billRequestDto: BillRequestDto = BillRequestDtoSchema.parse(
            JSON.parse(jsonString)
          );
          setBillRequest(toBillRequest(billRequestDto));
          createSuccessNotification("Bill imported successfully", 3000);
        } catch (error: any) {
          const message = Utils.getZodErrorMessages(error)[0];
          createErrorNotification(`Invalid bill specification: ${message}`);
        }
      })
      .catch(() => createErrorNotification("Error while importing file", 8000));
  }

  function handleExportFile() {
    const billRequestDto: BillRequestDto = toBillRequestDto(billRequest);
    const element = document.createElement("a");
    element.setAttribute(
      "href",
      "data:text/plain;charset=utf-8," +
        encodeURIComponent(JSON.stringify(billRequestDto, null, 2))
    );
    element.setAttribute("download", "bill.json");
    element.style.display = "none";
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
    createSuccessNotification("Bill specification exported successfully", 3000);
  }

  function waitForBill(id: number) {
    BillService.getBill(id)
      .then((bill) => {
        if (bill.error) {
          setIsGenerating(false);
          createErrorNotification(bill.errorMessage!, 5000);
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
      .catch((e) => {
        console.error(e);
        setIsGenerating(false);
        setBillId(undefined);
        createErrorNotification("Error while generating bill", 5000);
      });
  }

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (isGenerating) return;
    setIsGenerating(true);

    setTimeout(() => {
      BillService.generateBill(toBillRequestDto(billRequest))
        .then((id) => waitForBill(id))
        .catch(() => {
          setIsGenerating(false);
          createErrorNotification(
            "Error while generating bill, server is unreachable",
            5000
          );
        });
    }, 200);
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
          <NumberInput
            required
            label="Taxes (%)"
            value={billRequest.bill.taxes}
            onChange={(taxes) =>
              setBillRequest({
                ...billRequest,
                bill: { ...billRequest.bill, taxes },
              })
            }
          />
        </div>

        <div className={styles.BillGenerator_productList}>
          <ProductList
            currency={billRequest.config.currency}
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

        <NormalButton
          className={styles.BillGenerator_exportButton}
          type="button"
          onClick={handleExportFile}
        >
          <span>Export to file</span>
          <ExportIcon />
        </NormalButton>
      </form>
    </>
  );
}
