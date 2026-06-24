import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const repoRoot = process.cwd();

export function readKotobaVersion(): string {
  try {
    return readFileSync(resolve(repoRoot, "kotoba/VERSION"), "utf8").trim();
  } catch {
    return "dev";
  }
}

function readGitOrigin(): string {
  try {
    return readFileSync(resolve(repoRoot, ".git/config"), "utf8");
  } catch {
    return "";
  }
}

export function resolveGithubRepository(): string | undefined {
  if (process.env.DOCUSAURUS_GITHUB_REPO) {
    return process.env.DOCUSAURUS_GITHUB_REPO;
  }

  const config = readGitOrigin();
  const match = config.match(
    /\[remote "origin"\][\s\S]*?url = .*github\.com[:/]([^/\s]+)\/([^/\s.]+)/
  );
  if (match) {
    return `${match[1]}/${match[2]}`;
  }

  return undefined;
}

export function resolveOrganizationName(): string {
  const repo = resolveGithubRepository();
  if (repo) {
    return repo.split("/")[0];
  }
  return process.env.DOCUSAURUS_GITHUB_ORG ?? "mateo-m";
}

export function resolveProjectName(): string {
  if (process.env.DOCUSAURUS_REPOSITORY_NAME) {
    return process.env.DOCUSAURUS_REPOSITORY_NAME;
  }

  const repo = resolveGithubRepository();
  if (repo) {
    return repo.split("/")[1];
  }

  return "kotoba";
}

export function resolveSiteUrl(): string {
  if (process.env.DOCUSAURUS_URL) {
    return process.env.DOCUSAURUS_URL.replace(/\/$/, "");
  }

  const repo = resolveGithubRepository();
  if (repo) {
    const [org] = repo.split("/");
    return `https://${org}.github.io`;
  }

  return "https://mateo-m.github.io";
}

export function resolveBaseUrl(): string {
  if (process.env.NODE_ENV === "development") {
    return process.env.DOCUSAURUS_BASE ?? "/";
  }

  if (process.env.DOCUSAURUS_BASE) {
    return process.env.DOCUSAURUS_BASE;
  }

  return `/${resolveProjectName()}/`;
}

export function installDocPath(): string {
  try {
    const routing = JSON.parse(
      readFileSync(resolve(repoRoot, "docs/routing.json"), "utf8")
    ) as { install_path: string };
    return routing.install_path;
  } catch {
    return "essential/installation";
  }
}
