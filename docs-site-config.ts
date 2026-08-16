import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const repoRoot = process.cwd();

interface GithubRepository {
  branch: string;
  owner: string;
  repo: string;
}

function readGitOrigin(): string {
  try {
    return readFileSync(resolve(repoRoot, ".git/config"), "utf8");
  } catch {
    return "";
  }
}

/** Owner and repo for edit links and the header repo link. */
export function resolveGithub(): GithubRepository | undefined {
  const fromEnv = process.env.KOTOBA_DOCS_REPO;
  const [owner, repo] = fromEnv
    ? fromEnv.split("/")
    : (readGitOrigin().match(
        /\[remote "origin"\][\s\S]*?url = .*github\.com[:/]([^/\s]+)\/([^/\s.]+)/
      ) ?? []).slice(1);

  if (!(owner && repo)) {
    return undefined;
  }

  return { branch: "main", owner, repo };
}

/**
 * GitHub Pages does not tell the build its own URL, and Blume needs an absolute
 * origin for canonical links, the sitemap, and Open Graph images. Archived
 * versions depend on it too: each frozen page points its canonical at the
 * latest equivalent.
 */
export function resolveSiteUrl(): string | undefined {
  const fromEnv = process.env.KOTOBA_DOCS_URL;
  if (fromEnv) {
    return fromEnv.replace(/\/$/, "");
  }

  const github = resolveGithub();
  return github ? `https://${github.owner}.github.io` : undefined;
}

/**
 * GitHub Pages serves a project site under `/<repo>`, so the build needs that
 * base. Set `KOTOBA_DOCS_BASE=/` to build for a root domain instead.
 */
export function resolveBase(): string | undefined {
  const fromEnv = process.env.KOTOBA_DOCS_BASE;
  if (fromEnv) {
    return fromEnv === "/" ? undefined : fromEnv.replace(/\/$/, "");
  }

  // The dev server stays at the root, so local links match the published paths
  // without the project prefix.
  if (process.argv.includes("dev")) {
    return undefined;
  }

  const github = resolveGithub();
  return github ? `/${github.repo}` : undefined;
}

/** The install guide route, shared with the Ruby tooling through routing.json. */
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
