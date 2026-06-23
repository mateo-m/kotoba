import { defineConfig } from "vitepress";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { resolveBase } from "./repo";
import { buildSharedThemeConfig } from "./theme";

const docsDir = process.env.VITEPRESS_DOCS_DIR
  ? resolve(process.env.VITEPRESS_DOCS_DIR)
  : resolve(dirname(fileURLToPath(import.meta.url)), "..");

export default defineConfig({
  title: "Kotoba",
  description:
    "Internationalization for retro RPG Maker XP fan games and Pokemon Essentials projects.",
  base: resolveBase(),
  cleanUrls: true,
  lastUpdated: true,
  themeConfig: buildSharedThemeConfig(docsDir),
});
