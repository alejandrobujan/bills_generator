import { z } from "zod";
import {
  CurrencySchema,
  FontStyleSchema,
  LanguageSchema,
  PaperSizeSchema,
} from "./ConfigSchemas";
import PdfConfig, { PdfConfigSchema } from "./PdfConfig";

export const PdfConfigDtoSchema = z
  .object({
    currency: CurrencySchema.optional(),
    language: LanguageSchema.optional(),
    font_size: z.number().optional(),
    font_style: FontStyleSchema.optional(),
    paper_size: PaperSizeSchema.optional(),
    landscape: z.boolean().optional(),
  })
  .strict();

type PdfConfigDto = z.infer<typeof PdfConfigDtoSchema>;
export default PdfConfigDto;

export const getDefaultPdfConfigDto = (): PdfConfigDto => {
  return PdfConfigDtoSchema.parse({
    currency: "euro" as const,
    language: "en" as const,
    font_size: 12,
    font_style: "latex" as const,
    paper_size: "a4paper" as const,
    landscape: false,
  });
};

export const toPdfConfig = (dto: PdfConfigDto): PdfConfig => {
  return PdfConfigSchema.parse({
    currency: dto.currency,
    language: dto.language,
    fontSize: dto.font_size,
    fontStyle: dto.font_style,
    paperSize: dto.paper_size,
    landscape: dto.landscape,
  });
};
