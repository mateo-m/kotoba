import { defineConfig } from "vitepress";
import { resolveBase, resolveGithubRepository } from "./repo";

const githubRepository = resolveGithubRepository();

export default defineConfig({
  title: "Kotoba",
  description:
    "Internationalization for retro RPG Maker XP fan games and Pokemon Essentials projects.",
  base: resolveBase(),
  cleanUrls: true,
  lastUpdated: true,
  themeConfig: {
    nav: [
      { text: "Install", link: "/essential/installation" },
      { text: "Translators", link: "/translators/" },
      { text: "Guides", link: "/essential/catalog-format" },
      { text: "All docs", link: "/table-of-contents" },
    ],
    sidebar: [
      {
        text: "Getting started",
        collapsed: false,
        items: [
          { text: "Table of Contents", link: "/table-of-contents" },
          { text: "Installing in a game", link: "/essential/installation" },
          { text: "Quick Start (git clone)", link: "/essential/quick-start" },
          { text: "Troubleshooting", link: "/essential/troubleshooting" },
        ],
      },
      {
        text: "Core guides",
        collapsed: false,
        items: [
          { text: "Catalog format", link: "/essential/catalog-format" },
          { text: "Message syntax", link: "/essential/message-syntax" },
          { text: "Runtime API", link: "/essential/runtime-api" },
        ],
      },
      {
        text: "Integration",
        collapsed: true,
        items: [
          { text: "Overview", link: "/integration/" },
          { text: "Bare RGSS", link: "/integration/bare-rgss" },
          {
            text: "Pokemon Essentials",
            link: "/integration/pokemon-essentials",
          },
          { text: "Third-party adapters", link: "/integration/third-party" },
          {
            text: "Essentials migration",
            link: "/integration/pokemon-essentials-migration",
          },
        ],
      },
      {
        text: "For translators",
        collapsed: false,
        items: [
          { text: "For translators", link: "/translators/" },
          { text: "Placeholders", link: "/translators/placeholders" },
          { text: "Spreadsheet handoff", link: "/translators/handoff" },
        ],
      },
      {
        text: "Tooling",
        collapsed: true,
        items: [
          { text: "Overview", link: "/tooling/" },
          { text: "Validation CLI", link: "/tooling/validation-cli" },
          { text: "TMS workflows", link: "/tooling/tms" },
          { text: "Crowdin", link: "/tooling/crowdin" },
          { text: "SimpleLocalize", link: "/tooling/simplelocalize" },
          { text: "Tolgee", link: "/tooling/tolgee" },
          { text: "XLIFF and PO", link: "/tooling/xliff-po" },
        ],
      },
      {
        text: "Reference",
        collapsed: true,
        items: [
          { text: "Map event codes", link: "/reference/map-event-codes" },
          { text: "Compatibility", link: "/reference/compatibility" },
        ],
      },
      {
        text: "Contributors",
        collapsed: true,
        items: [
          { text: "CI", link: "/contributors/ci" },
          { text: "Docker images", link: "/contributors/docker-images" },
          { text: "Roadmap", link: "/contributors/roadmap" },
        ],
      },
    ],
    socialLinks: githubRepository
      ? [{ icon: "github", link: `https://github.com/${githubRepository}` }]
      : [],
    search: {
      provider: "local",
    },
  },
});
