import { Number, Record, Static, Union, Literal } from "runtypes";

export enum FontFamily {
  "Arial",
  "Times New Roman",
  "Courier New",
}

const FontFamilySchema = Union(
  Literal("Arial"),
  Literal("Times New Roman"),
  Literal("Courier New")
);

export const PdfConfigSchema = Record({
  fontSize: Number.withConstraint((fontSize) => fontSize > 0).optional(),
  fontFamily: FontFamilySchema.optional(),
});

type PdfConfig = Static<typeof PdfConfigSchema>;

export const getDefaultConfig = () => {
  return {
    fontFamily: "Arial" as const,
    fontSize: 12,
  };
};

export default PdfConfig;
