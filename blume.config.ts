import { defineConfig } from "blume";
import {
  installDocPath,
  resolveBase,
  resolveGithub,
  resolveSiteUrl,
} from "./docs-site-config";

const github = resolveGithub();

export default defineConfig({
  title: "Kotoba",
  description: "i18n for RPG Maker XP and Pokemon Essentials",

  github,

  navigation: {
    featured: [
      { label: "Install", href: `/${installDocPath()}`, icon: "download" },
    ],
  },

  versions: {
    current: { label: "latest", badge: "Latest" },
    archived: [{ id: "v0.1.0" }],
  },

  theme: {
    accent: { light: "#e85d04", dark: "#fb923c" },
    background: { light: "#fbf6f0", dark: "#100c0a" },
    radius: "sm",
    mode: "system",
    fonts: {
      body: "dm-sans",
      display: "dm-sans",
    },
  },

  markdown: {
    codeBlocks: {
      theme: {
        light: "github-light",
        dark: "github-dark",
      },
    },
  },

  toc: {
    minHeadingLevel: 2,
    maxHeadingLevel: 4,
  },

  deployment: {
    base: resolveBase(),
    site: resolveSiteUrl(),
  },
});
