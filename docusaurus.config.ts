import type { Config } from "@docusaurus/types";
import {
  installDocPath,
  readKotobaVersion,
  resolveBaseUrl,
  resolveGithubRepository,
  resolveOrganizationName,
  resolveProjectName,
  resolveSiteUrl,
} from "./docs-site-config";
import { kotobaDark, kotobaLight } from "./src/prism-kotoba";

const githubRepository = resolveGithubRepository();
const installPath = installDocPath();

const config: Config = {
  title: "Kotoba",
  tagline: "i18n for RPG Maker XP and Pokemon Essentials",
  url: resolveSiteUrl(),
  baseUrl: resolveBaseUrl(),
  organizationName: resolveOrganizationName(),
  projectName: resolveProjectName(),
  onBrokenLinks: "throw",
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: "warn",
    },
  },
  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },
  presets: [
    [
      "classic",
      {
        docs: {
          routeBasePath: "/",
          sidebarPath: "./sidebars.ts",
          lastVersion: "current",
          versions: {
            current: {
              label: "latest",
            },
          },
          editUrl: githubRepository
            ? `https://github.com/${githubRepository}/edit/main/`
            : undefined,
        },
        blog: false,
        theme: {
          customCss: "./src/css/custom.css",
        },
      },
    ],
  ],
  themeConfig: {
    colorMode: {
      defaultMode: "light",
      respectPrefersColorScheme: true,
    },
    tableOfContents: {
      minHeadingLevel: 2,
      maxHeadingLevel: 4,
    },
    navbar: {
      title: "Kotoba",
      items: [
        {
          type: "docsVersionDropdown",
          position: "left",
        },
        {
          to: "/introduction",
          label: "Guide",
          activeBaseRegex: "/introduction",
        },
        {
          to: `/${installPath}`,
          label: "Install",
          activeBaseRegex: `/${installPath.replace(/\//g, "\\/")}`,
        },
        {
          to: "/integration/",
          label: "Integration",
          activeBaseRegex: "/integration/",
        },
        {
          to: "/translators/",
          label: "Translators",
          activeBaseRegex: "/translators/",
        },
        {
          to: "/essential/catalog-format",
          label: "Catalog & API",
          activeBaseRegex: "/essential/(catalog-format|message-syntax|runtime-api)",
        },
        ...(githubRepository
          ? [
              {
                href: `https://github.com/${githubRepository}`,
                "aria-label": "GitHub repository",
                className: "header-github-link",
                position: "right" as const,
              },
            ]
          : []),
      ],
    },
    footer: {
      style: "light",
      copyright: `Kotoba ${readKotobaVersion()} · MIT · ${resolveProjectName()}`,
    },
    prism: {
      theme: kotobaLight,
      darkTheme: kotobaDark,
      additionalLanguages: ["ruby", "bash", "json"],
    },
  },
};

export default config;
