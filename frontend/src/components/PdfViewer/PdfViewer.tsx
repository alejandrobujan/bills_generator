import styles from "./pdfViewer.module.scss";

interface Props {
  file: Blob;
}

export default function PdfViewer({ file }: Props) {
  return (
    <div className={styles.PdfViewer_container}>
      <embed
        src="/practica1.pdf"
        type="application/pdf"
        width="100%"
        height="100%"
      />
    </div>
  );
}
