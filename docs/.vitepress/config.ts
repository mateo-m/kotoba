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
      { text: "Docs", link: "/table-of-contents" },
      { text: "Quick Start", link: "/essential/quick-start" },
      { text: "Integration", link: "/integration/" },
      { text: "Tooling", link: "/tooling/" },
    ],
    sidebar: [
      {
        text: "Introduction",
        collapsed: false,
        items: [
          { text: "Table of Contents", link: "/table-of-contents" },
          { text: "Quick Start", link: "/essential/quick-start" },
          { text: "Installing In A Game", link: "/essential/installation" },
        ],
      },
      {
        text: "Essential",
        collapsed: false,
        items: [
          { text: "Catalog Format", link: "/essential/catalog-format" },
          { text: "Message Syntax", link: "/essential/message-syntax" },
          { text: "Runtime API", link: "/essential/runtime-api" },
        ],
      },
      {
        text: "Integration",
        collapsed: false,
        items: [
          { text: "Overview", link: "/integration/" },
          { text: "Bare RGSS", link: "/integration/bare-rgss" },
          {
            text: "Pokemon Essentials",
            link: "/integration/pokemon-essentials",
          },
          { text: "Third-Party Adapters", link: "/integration/third-party" },
          {
            text: "Essentials Migration",
            link: "/integration/pokemon-essentials-migration",
          },
        ],
      },
      {
        text: "Tooling",
        collapsed: false,
        items: [
          { text: "Overview", link: "/tooling/" },
          { text: "Validation CLI", link: "/tooling/validation-cli" },
          { text: "TMS Workflows", link: "/tooling/tms" },
          { text: "Crowdin", link: "/tooling/crowdin" },
          { text: "SimpleLocalize", link: "/tooling/simplelocalize" },
          { text: "Tolgee", link: "/tooling/tolgee" },
          { text: "XLIFF And PO", link: "/tooling/xliff-po" },
        ],
      },
      {
        text: "Reference",
        collapsed: true,
        items: [
          { text: "Map Event Codes", link: "/reference/map-event-codes" },
          { text: "Compatibility", link: "/reference/compatibility" },
        ],
      },
      {
        text: "Contributors",
        collapsed: true,
        items: [
          { text: "CI", link: "/contributors/ci" },
          { text: "Docker Images", link: "/contributors/docker-images" },
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
