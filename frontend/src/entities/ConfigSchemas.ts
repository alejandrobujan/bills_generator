import { z } from "zod";
import PdfConfig from "./PdfConfig";

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

export const CurrencySchema = z.union([z.literal("euro"), z.literal("dollar")]);

export const LanguageSchema = z.union([
  z.literal("en"),
  z.literal("es"),
  z.literal("gl"),
]);

// Maps to get const strings from enum values

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

export const currencyMap = new Map([
  ["euro", "euro" as const],
  ["dollar", "dollar" as const],
]);

export const languageMap = new Map([
  ["en", "en" as const],
  ["es", "es" as const],
  ["gl", "gl" as const],
]);

const currencyToSymbolMap = new Map([
  ["euro", "€"],
  ["dollar", "$"],
]);
export const getCurrencySymbol = (currency: PdfConfig["currency"]) => {
  return currencyToSymbolMap.get(currency);
};
