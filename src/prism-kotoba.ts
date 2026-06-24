import type { PrismTheme } from "prism-react-renderer";

export const kotobaLight: PrismTheme = {
  plain: {
    backgroundColor: "#faf3ec",
    color: "#2a231e",
  },
  styles: [
    {
      types: ["comment", "prolog", "cdata"],
      style: { color: "#958578", fontStyle: "italic" },
    },
    {
      types: ["doctype", "punctuation", "entity"],
      style: { color: "#75685c" },
    },
    {
      types: [
        "attr-name",
        "class-name",
        "maybe-class-name",
        "boolean",
        "constant",
        "number",
        "atrule",
      ],
      style: { color: "#c2410c" },
    },
    {
      types: ["keyword"],
      style: { color: "#9a3412", fontWeight: "600" },
    },
    {
      types: ["property", "tag", "symbol", "deleted", "important"],
      style: { color: "#ea580c" },
    },
    {
      types: ["selector", "string", "char", "builtin", "inserted", "regex", "attr-value"],
      style: { color: "#7a6238" },
    },
    {
      types: ["variable", "operator", "function"],
      style: { color: "#e85d04" },
    },
    {
      types: ["url"],
      style: { color: "#b45309" },
    },
  ],
};

export const kotobaDark: PrismTheme = {
  plain: {
    backgroundColor: "#1a1512",
    color: "#f0e6dc",
  },
  styles: [
    {
      types: ["comment", "prolog", "cdata"],
      style: { color: "#958578", fontStyle: "italic" },
    },
    {
      types: ["doctype", "punctuation", "entity"],
      style: { color: "#b8a896" },
    },
    {
      types: [
        "attr-name",
        "class-name",
        "maybe-class-name",
        "boolean",
        "constant",
        "number",
        "atrule",
      ],
      style: { color: "#fdba74" },
    },
    {
      types: ["keyword"],
      style: { color: "#fb923c", fontWeight: "600" },
    },
    {
      types: ["property", "tag", "symbol", "deleted", "important"],
      style: { color: "#f97316" },
    },
    {
      types: ["selector", "string", "char", "builtin", "inserted", "regex", "attr-value"],
      style: { color: "#c9a86c" },
    },
    {
      types: ["variable", "operator", "function"],
      style: { color: "#fed7aa" },
    },
    {
      types: ["url"],
      style: { color: "#fbbf24" },
    },
  ],
};
