#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

REPO_NAME="${VITEPRESS_REPOSITORY_NAME:-}"
if [[ -z "$REPO_NAME" ]]; then
  site_url="$(bin/docs-site-url 2>/dev/null || true)"
  if [[ -n "$site_url" ]]; then
    REPO_NAME="${site_url##*/}"
  fi
fi
if [[ -z "$REPO_NAME" ]]; then
  REPO_NAME="kotoba"
fi

LATEST_BASE="${VITEPRESS_BASE:-/${REPO_NAME}/}"
STAGING="$REPO_ROOT/.docs-site-staging"
DIST="$REPO_ROOT/docs/.vitepress/dist"
SHARED_VITEPRESS="$REPO_ROOT/docs/.vitepress"

rm -rf "$STAGING"
mkdir -p "$STAGING"

echo "==> building latest docs ($LATEST_BASE)"
VITEPRESS_BASE="$LATEST_BASE" \
  VITEPRESS_REPOSITORY_NAME="$REPO_NAME" \
  bun run docs:build
cp -R "$DIST"/* "$STAGING/"

for snap in "$REPO_ROOT"/docs-versions/v*/; do
  [[ -d "$snap" ]] || continue
  ver=$(basename "$snap")
  ver_base="${LATEST_BASE}${ver}/"
  snap_vitepress="$snap/.vitepress"

  echo "==> building $ver docs ($ver_base)"
  rm -rf "$snap_vitepress"
  rsync -a \
    --exclude dist \
    --exclude cache \
    --exclude .temp \
    "$SHARED_VITEPRESS/" "$snap_vitepress/"

  VITEPRESS_DOCS_DIR="$snap" \
  VITEPRESS_BASE="$ver_base" \
  VITEPRESS_REPOSITORY_NAME="$REPO_NAME" \
    bunx vitepress build "$snap"

  mkdir -p "$STAGING/$ver"
  cp -R "$snap_vitepress/dist"/* "$STAGING/$ver/"
  rm -rf "$snap_vitepress"
done

rm -rf "$DIST"
mkdir -p "$DIST"
cp -R "$STAGING"/* "$DIST/"
rm -rf "$STAGING"

touch "$DIST/.nojekyll"

echo "==> normalizing dist for GitHub Pages"
bun "$REPO_ROOT/scripts/normalize-docs-dist-for-pages.ts" "$DIST"

echo "==> checking docs site output"
bash "$REPO_ROOT/bin/check-docs-site" "$DIST"

echo "==> docs site ready at docs/.vitepress/dist"
