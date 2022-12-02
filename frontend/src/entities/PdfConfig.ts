import { Number, Record, Static, Union, Literal } from "runtypes";

const FontStyleSchema = Union(
  Literal("latex"),
  Literal("times"),
);

export const PdfConfigSchema = Record({
  font_size: Number.withConstraint((font_size) => font_size > 0).optional(),
  font_style: FontStyleSchema.optional(),
});

type PdfConfig = Static<typeof PdfConfigSchema>;

export const getDefaultConfig = () => {
  return {
    font_style: "latex" as const,
    font_size: 12,
  };
};

export default PdfConfig;
