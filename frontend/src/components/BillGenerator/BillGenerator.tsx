import styles from "./billGenerator.module.scss";
import ArrowFwdIcon from "@mui/icons-material/ArrowForwardIos";
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
import Utils from "../../utils/utils";
import PdfViewer from "../PdfViewer/PdfViewer";
import PdfConfiguration from "../PdfConfiguration/PdfConfiguration";
import PdfConfig, { getDefaultConfig } from "../../entities/PdfConfig";

export default function BillGenerator() {
  const { createErrorNotification } = useNotifications();
  const [generatedBill, setGeneratedBill] = useState<Blob | undefined>(
    undefined
  );
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

        setFormState({
          user: completeBill.user,
          bill: {
            ...formState.bill,
            seller: completeBill.bill.seller,
            purchaser: completeBill.bill.purchaser,
            products: productsWithId,
          },
          config: completeBill.config ?? getDefaultConfig(),
        });
      } catch (error: any) {
        createErrorNotification("Invalid bill specification", 8000);
        return;
      }
    });
  }

  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setIsGenerating(true);
    const billDto: BillDto = BillDtoSchema.check(formState);
    BillService.generateBill(billDto).then((id) => waitForBill(id));
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

        <NormalButton
          type="submit"
          className={styles.BillGenerator_generateButton}
        >
          <span>Generate</span>
          <ArrowFwdIcon />
        </NormalButton>
      </form>

      <div className={styles.BillGenerator_billPdfContainer}>
        {isGenerating ? (
          <div className={styles.BillGenerator_loading}>
            <span>Generating bill...</span>
          </div>
        ) : (
          !generatedBill && <PdfViewer file={generatedBill!} />
        )}
      </div>
    </>
  );
}
