import {
  mkdirSync,
  readdirSync,
  readFileSync,
  renameSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { basename, join } from "node:path";

const dist = process.argv[2];
if (!dist) {
  console.error("usage: bun scripts/normalize-docs-dist-for-pages.ts DIST");
  process.exit(1);
}

function walkHtmlFiles(dir: string): string[] {
  const result: string[] = [];
  for (const name of readdirSync(dir)) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) {
      result.push(...walkHtmlFiles(path));
    } else if (name.endsWith(".html")) {
      result.push(path);
    }
  }
  return result;
}

function convertFlatPagesToDirectories(): void {
  const htmlFiles = walkHtmlFiles(dist).sort((a, b) => b.length - a.length);
  for (const file of htmlFiles) {
    const name = basename(file);
    if (name === "index.html" || name === "404.html") {
      continue;
    }
    const targetDir = file.slice(0, -".html".length);
    mkdirSync(targetDir, { recursive: true });
    renameSync(file, join(targetDir, "index.html"));
  }
}

function needsTrailingSlash(path: string): boolean {
  if (!path.startsWith("/")) {
    return false;
  }
  if (path === "/") {
    return false;
  }
  if (path.endsWith("/")) {
    return false;
  }
  if (/\.[a-zA-Z0-9]{2,5}$/.test(path)) {
    return false;
  }
  return true;
}

function trailingSlashPath(path: string): string {
  const hashIndex = path.indexOf("#");
  if (hashIndex === -1) {
    return needsTrailingSlash(path) ? `${path}/` : path;
  }
  const base = path.slice(0, hashIndex);
  const hash = path.slice(hashIndex);
  return needsTrailingSlash(base) ? `${base}/${hash}` : path;
}

function patchInternalPath(path: string): string {
  return trailingSlashPath(path);
}

function patchHtml(html: string): string {
  let out = html.replace(/href="(\/[^"]+)"/g, (match, path: string) => {
    const next = patchInternalPath(path);
    return next === path ? match : `href="${next}"`;
  });

  out = out.replace(/\\"link\\":\\"(\/[^\\"]+)\\"/g, (match, path: string) => {
    const next = patchInternalPath(path);
    return next === path ? match : `\\"link\\":\\"${next}\\"`;
  });

  return out;
}

function patchHtmlFiles(): void {
  for (const file of walkHtmlFiles(dist)) {
    const source = readFileSync(file, "utf8");
    const patched = patchHtml(source);
    if (patched !== source) {
      writeFileSync(file, patched);
    }
  }
}

convertFlatPagesToDirectories();
patchHtmlFiles();

console.log(`normalized docs dist for GitHub Pages (${dist})`);
