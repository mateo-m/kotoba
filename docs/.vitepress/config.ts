import { defineConfig } from "vitepress";

const repositoryName =
  process.env.VITEPRESS_REPOSITORY_NAME || "rpg-maker-i18n";
const githubRepository = process.env.VITEPRESS_GITHUB_REPO;

export default defineConfig({
  title: "RPG Maker i18n",
  description:
    "Ruby internationalization for RPG Maker XP and Pokemon Essentials projects.",
  base: process.env.VITEPRESS_BASE || `/${repositoryName}/`,
  cleanUrls: true,
  lastUpdated: true,
  themeConfig: {
    nav: [
      { text: "Guide", link: "/getting-started" },
      { text: "Adapters", link: "/adapters/" },
      { text: "Tooling", link: "/tooling/tms" },
      { text: "Roadmap", link: "/roadmap" },
    ],
    sidebar: [
      {
        text: "Start Here",
        items: [
          { text: "Getting Started", link: "/getting-started" },
          { text: "Runtime API", link: "/runtime-api" },
          { text: "Catalog Format", link: "/catalog-format" },
          { text: "Message Syntax", link: "/message-syntax" },
          { text: "Validation CLI", link: "/validation-cli" },
        ],
      },
      {
        text: "Integration",
        items: [
          { text: "Adapters Overview", link: "/adapters/" },
          { text: "Bare RGSS", link: "/adapters/bare-rgss" },
          { text: "Pokemon Essentials", link: "/adapters/pokemon-essentials" },
          { text: "Third-Party Adapters", link: "/adapters/third-party" },
        ],
      },
      {
        text: "Tooling",
        items: [
          { text: "TMS Workflows", link: "/tooling/tms" },
          { text: "Crowdin", link: "/tooling/crowdin" },
          { text: "SimpleLocalize", link: "/tooling/simplelocalize" },
          { text: "Tolgee", link: "/tooling/tolgee" },
          { text: "XLIFF And PO", link: "/tooling/xliff-po" },
        ],
      },
      {
        text: "Project Notes",
        items: [
          {
            text: "Pokemon Essentials Migration",
            link: "/migration/pokemon-essentials",
          },
          { text: "Compatibility", link: "/compatibility" },
          { text: "Docker Images", link: "/docker-images" },
          { text: "CI", link: "/ci" },
          { text: "Roadmap", link: "/roadmap" },
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
