import { existsSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

export type DocsRouting = {
  install_path: string;
  version_path_template: string;
};

let cachedRouting: DocsRouting | undefined;

function resolveRoutingManifestPath(): string {
  const vitepressDir = dirname(fileURLToPath(import.meta.url));
  const candidates = [
    join(vitepressDir, "..", "routing.json"),
    join(vitepressDir, "..", "..", "..", "docs", "routing.json"),
  ];

  for (const path of candidates) {
    if (existsSync(path)) {
      return path;
    }
  }

  throw new Error("docs routing manifest (routing.json) not found");
}

export function readDocsRouting(): DocsRouting {
  if (cachedRouting) {
    return cachedRouting;
  }

  cachedRouting = JSON.parse(readFileSync(resolveRoutingManifestPath(), "utf8")) as DocsRouting;
  return cachedRouting;
}

export function resolveInstallPath(): string {
  return readDocsRouting().install_path;
}

export function resolveVersionedInstallPath(version: string): string {
  const routing = readDocsRouting();
  return routing.version_path_template
    .replace("{version}", version)
    .replace("{install_path}", routing.install_path);
}

export function resolveInstallUrl(siteUrl: string, version: string): string {
  return `${siteUrl.replace(/\/$/, "")}/${resolveVersionedInstallPath(version)}`;
}
