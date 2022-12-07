import { z } from "zod";
import PdfConfigDto, {
  FontStyleSchema,
  PaperSizeSchema,
  PdfConfigDtoSchema,
} from "./PdfConfigDto";

export const PdfConfigSchema = z
  .object({
    fontStyle: FontStyleSchema.optional(),
    fontSize: z.number().optional(),
    paperSize: PaperSizeSchema.optional(),
    landscape: z.boolean().optional(),
  })
  .strict();

type PdfConfig = z.infer<typeof PdfConfigSchema>;
export default PdfConfig;

export const getDefaultPdfConfig = () => {
  return PdfConfigSchema.parse({
    fontStyle: "latex" as const,
    fontSize: 12,
    paperSize: "a4paper" as const,
    landscape: false,
  });
};

export const toPdfConfigDto = (config: PdfConfig): PdfConfigDto => {
  return PdfConfigDtoSchema.parse({
    font_size: config.fontSize,
    font_style: config.fontStyle,
    paper_size: config.paperSize,
    landscape: config.landscape,
  });
};
