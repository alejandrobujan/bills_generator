import { z } from "zod";
import PdfConfig, { PdfConfigSchema } from "./PdfConfig";

export const FontStyleSchema = z.union([
  z.literal("latex"),
  z.literal("times"),
]);

export const PaperSizeSchema = z.union([
  z.literal("a4paper"),
  z.literal("a5paper"),
  z.literal("b5paper"),
  z.literal("executivepaper"),
  z.literal("legalpaper"),
  z.literal("letterpaper"),
]);

export const fontStyleMap = new Map([
  ["latex", "latex" as const],
  ["times", "times" as const],
]);

export const paperSizeMap = new Map([
  ["a4paper", "a4paper" as const],
  ["a5paper", "a5paper" as const],
  ["b5paper", "b5paper" as const],
  ["executivepaper", "executivepaper" as const],
  ["legalpaper", "legalpaper" as const],
  ["letterpaper", "letterpaper" as const],
]);

export const PdfConfigDtoSchema = z
  .object({
    font_size: z.number().optional(),
    font_style: FontStyleSchema.optional(),
    paper_size: PaperSizeSchema.optional(),
    landscape: z.boolean().optional(),
  })
  .strict();

type PdfConfigDto = z.infer<typeof PdfConfigDtoSchema>;
export default PdfConfigDto;

export const toPdfConfig = (dto: PdfConfigDto): PdfConfig => {
  return PdfConfigSchema.parse({
    fontSize: dto.font_size,
    fontStyle: dto.font_style,
    paperSize: dto.paper_size,
    landscape: dto.landscape,
  });
};
