import type { DefaultTheme } from "vitepress";
import { readFileSync, existsSync, readdirSync } from "node:fs";
import { resolve } from "node:path";
import {
  isVersionedDocsBase,
  resolveBase,
  resolveDocsSiteUrl,
  resolveGithubRepository,
  resolveRepositoryName,
} from "./repo";

function repoRootFromDocs(docsDir: string): string {
  const parent = resolve(docsDir, "..");
  if (existsSync(resolve(parent, "kotoba", "VERSION"))) {
    return parent;
  }
  return resolve(docsDir, "../..");
}

export function readKotobaVersion(docsDir: string): string {
  try {
    return readFileSync(resolve(repoRootFromDocs(docsDir), "kotoba/VERSION"), "utf8").trim();
  } catch {
    return "dev";
  }
}

export function listedDocVersions(docsDir: string): string[] {
  const versionsDir = resolve(repoRootFromDocs(docsDir), "docs-versions");
  if (!existsSync(versionsDir)) {
    return [];
  }

  return readdirSync(versionsDir)
    .filter((name) => /^v\d+\.\d+\.\d+$/.test(name))
    .sort()
    .reverse();
}

export function versionSwitcherItems(docsDir: string): DefaultTheme.NavItemWithChildren["items"] {
  const versions = listedDocVersions(docsDir);
  const versionedBuild = isVersionedDocsBase();
  const siteUrl = resolveDocsSiteUrl();
  const crossSiteLinks = versionedBuild && siteUrl;
  const sameTab = crossSiteLinks ? { target: "_self" as const } : {};

  const linkFor = (version: "latest" | string): string => {
    if (crossSiteLinks) {
      return version === "latest" ? `${siteUrl}/` : `${siteUrl}/${version}/`;
    }
    return version === "latest" ? "/" : `/${version}/`;
  };

  const items: DefaultTheme.NavItemWithChildren["items"] = [
    { text: "latest", link: linkFor("latest"), ...sameTab },
  ];

  for (const version of versions) {
    items.push({ text: version, link: linkFor(version), ...sameTab });
  }

  return items;
}

export function activeDocLabel(docsDir: string): string {
  const base = resolveBase();
  const match = base.match(/\/(v\d+\.\d+\.\d+)\/$/);
  if (match) {
    return match[1];
  }

  const versions = listedDocVersions(docsDir);
  return versions.length > 0 ? "latest" : `v${readKotobaVersion(docsDir)}`;
}

export function buildSharedThemeConfig(docsDir: string): DefaultTheme.Config {
  const githubRepository = resolveGithubRepository();
  const versionItems = versionSwitcherItems(docsDir);
  const nav: DefaultTheme.NavItem[] = [];

  if (versionItems.length > 1) {
    nav.push({
      text: activeDocLabel(docsDir),
      items: versionItems,
    });
  } else {
    nav.push({ text: `v${readKotobaVersion(docsDir)}`, link: "/" });
  }

  nav.push(
    { text: "Install", link: "/essential/installation" },
    { text: "Integration", link: "/integration/" },
    { text: "Translators", link: "/translators/" },
    { text: "Catalog & API", link: "/essential/catalog-format" },
  );

  const repoName = resolveRepositoryName();

  return {
    nav,
    sidebar: [
      {
        text: "Getting started",
        collapsed: false,
        items: [
          { text: "Installing in a game", link: "/essential/installation" },
          { text: "Quick Start (git clone)", link: "/essential/quick-start" },
          { text: "Troubleshooting", link: "/essential/troubleshooting" },
        ],
      },
      {
        text: "Integration",
        collapsed: false,
        items: [
          { text: "Pick your kit", link: "/integration/" },
          { text: "Bare RGSS", link: "/integration/bare-rgss" },
          {
            text: "Pokemon Essentials",
            link: "/integration/pokemon-essentials",
          },
          {
            text: "Essentials migration",
            link: "/integration/pokemon-essentials-migration",
          },
          { text: "Third-party adapters", link: "/integration/third-party" },
        ],
      },
      {
        text: "Catalog & API",
        collapsed: true,
        items: [
          { text: "Catalog format", link: "/essential/catalog-format" },
          { text: "Message syntax", link: "/essential/message-syntax" },
          { text: "Runtime API", link: "/essential/runtime-api" },
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
        text: "Specs",
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
        ],
      },
    ],
    socialLinks: githubRepository
      ? [{ icon: "github", link: `https://github.com/${githubRepository}` }]
      : [],
    search: {
      provider: "local",
    },
    footer: {
      message: `Kotoba ${readKotobaVersion(docsDir)}`,
      copyright: repoName ? `MIT · ${repoName}` : "MIT Licensed",
    },
  };
}
