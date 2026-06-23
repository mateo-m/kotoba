import { execSync } from "node:child_process";

export type GitOrigin = {
  name?: string;
  githubRepo?: string;
};

export function readGitOrigin(): GitOrigin {
  try {
    const remote = execSync("git remote get-url origin", { encoding: "utf8" }).trim();
    const github = remote.match(/github\.com[:/]([^/]+)\/([^/]+?)(?:\.git)?$/);
    if (github) {
      return { name: github[2], githubRepo: `${github[1]}/${github[2]}` };
    }

    const tail = remote.match(/\/([^/]+?)(?:\.git)?$/);
    if (tail) {
      return { name: tail[1] };
    }
  } catch {
    // Local checkout without git or origin.
  }

  return {};
}

export function resolveRepositoryName(): string | undefined {
  return process.env.VITEPRESS_REPOSITORY_NAME || readGitOrigin().name;
}

export function resolveGithubRepository(): string | undefined {
  return process.env.VITEPRESS_GITHUB_REPO || readGitOrigin().githubRepo;
}

export function resolveBase(): string {
  if (process.env.VITEPRESS_BASE) {
    return process.env.VITEPRESS_BASE;
  }

  const repositoryName = resolveRepositoryName();
  if (repositoryName) {
    return `/${repositoryName}/`;
  }

  return "/";
}

export function isVersionedDocsBase(base: string = resolveBase()): boolean {
  return /\/v\d+\.\d+\.\d+\/$/.test(base);
}

export function resolveDocsSiteUrl(): string | undefined {
  const explicit = process.env.KOTOBA_DOCS_URL;
  if (explicit) {
    return explicit.replace(/\/$/, "");
  }

  const { githubRepo } = readGitOrigin();
  if (!githubRepo) {
    return undefined;
  }

  const [owner, repo] = githubRepo.split("/");
  return `https://${owner}.github.io/${repo}`;
}
