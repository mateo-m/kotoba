import type { Config } from "@docusaurus/types";
import { themes as prismThemes } from "prism-react-renderer";
import {
  installDocPath,
  readKotobaVersion,
  resolveBaseUrl,
  resolveGithubRepository,
  resolveOrganizationName,
  resolveProjectName,
  resolveSiteUrl,
} from "./docs-site-config";

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
    navbar: {
      title: "Kotoba",
      items: [
        {
          type: "docsVersionDropdown",
          position: "left",
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
      style: "dark",
      copyright: `Kotoba ${readKotobaVersion()} · MIT · ${resolveProjectName()}`,
    },
    prism: {
      theme: prismThemes.oneLight,
      darkTheme: prismThemes.oneDark,
      additionalLanguages: ["ruby", "bash", "json"],
    },
  },
};

export default config;
