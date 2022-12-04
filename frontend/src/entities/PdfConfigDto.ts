import { Number, Record, Static, Union, Literal, Boolean } from "runtypes";
import PdfConfig from "./PdfConfig";

export const FontStyleSchema = Union(Literal("latex"), Literal("times"));
export const PaperSizeSchema = Union(
  Literal("a4paper"),
  Literal("a5paper"),
  Literal("b5paper"),
  Literal("executivepaper"),
  Literal("legalpaper"),
  Literal("letterpaper")
);

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

export const PdfConfigDtoSchema = Record({
  font_size: Number.withConstraint((font_size) => font_size > 0).optional(),
  font_style: FontStyleSchema.optional(),
  paper_size: PaperSizeSchema.optional(),
  landscape: Boolean.optional(),
});

type PdfConfigDto = Static<typeof PdfConfigDtoSchema>;
export default PdfConfigDto;

export const toPdfConfig = (dto: PdfConfigDto): PdfConfig => {
  return {
    fontSize: dto.font_size,
    fontStyle: dto.font_style,
    paperSize: dto.paper_size,
    landscape: dto.landscape,
  };
};
