import { Number, Record, Static, Union, Literal, Boolean } from "runtypes";
import PdfConfigDto, { FontStyleSchema, PaperSizeSchema } from "./PdfConfigDto";

export const PdfConfigSchema = Record({
  fontSize: Number.withConstraint((font_size) => font_size > 0).optional(),
  fontStyle: FontStyleSchema.optional(),
  paperSize: PaperSizeSchema.optional(),
  landscape: Boolean.optional(),
});

type PdfConfig = Static<typeof PdfConfigSchema>;
export default PdfConfig;

export const getDefaultPdfConfig = () => {
  return {
    fontStyle: "latex" as const,
    fontSize: 12,
    paperSize: "a4paper" as const,
    landscape: false,
  };
};

export const toPdfConfigDto = (config: PdfConfig): PdfConfigDto => {
  return {
    font_size: config.fontSize,
    font_style: config.fontStyle,
    paper_size: config.paperSize,
    landscape: config.landscape,
  };
};
