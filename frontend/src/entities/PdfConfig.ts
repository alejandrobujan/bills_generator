import { z } from "zod";
import {
  CurrencySchema,
  FontStyleSchema,
  LanguageSchema,
  PaperSizeSchema,
} from "./ConfigSchemas";
import PdfConfigDto, { PdfConfigDtoSchema } from "./PdfConfigDto";

export const PdfConfigSchema = z
  .object({
    currency: CurrencySchema,
    language: LanguageSchema,
    fontStyle: FontStyleSchema,
    fontSize: z.number(),
    paperSize: PaperSizeSchema,
    landscape: z.boolean(),
  })
  .strict();

type PdfConfig = z.infer<typeof PdfConfigSchema>;
export default PdfConfig;

export const getDefaultPdfConfig = () => {
  return PdfConfigSchema.parse({
    currency: "euro" as const,
    language: "en" as const,
    fontStyle: "latex" as const,
    fontSize: 12,
    paperSize: "a4paper" as const,
    landscape: false,
  });
};

export const toPdfConfigDto = (config: PdfConfig): PdfConfigDto => {
  return PdfConfigDtoSchema.parse({
    currency: config.currency,
    language: config.language,
    font_size: config.fontSize,
    font_style: config.fontStyle,
    paper_size: config.paperSize,
    landscape: config.landscape,
  });
};
