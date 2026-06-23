#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION_FILE="$REPO_ROOT/kotoba/VERSION"
DIST_DIR="$REPO_ROOT/dist"
# shellcheck source=scripts/changelog-release.sh
source "$REPO_ROOT/scripts/changelog-release.sh"

usage() {
    echo "usage: $0 <bump>"
    echo "  bump   major | minor | patch     bump latest tag's segment"
    echo "         <semver>                  explicit version (e.g. 0.1.0)"
    echo ""
    echo "Every release run:"
    echo "  1. verifies a clean tree and release tooling"
    echo "  2. bumps kotoba/VERSION and prepends CHANGELOG.md"
    echo "  3. runs bun run lint (set RELEASE_SKIP_LINT=1 to skip)"
    echo "  4. builds integration ZIPs into dist/"
    echo "  5. commits, signs the tag, pushes, and creates the GitHub release"
    exit 1
}

[[ $# -eq 1 ]] || usage
BUMP_OR_VERSION="$1"

case "$BUMP_OR_VERSION" in
    major | minor | patch)
        LATEST_TAG=$(git -C "$REPO_ROOT" tag --list "v*.*.*" --sort=-v:refname | head -n 1)
        if [[ -z "$LATEST_TAG" ]]; then
            if [[ -f "$VERSION_FILE" ]]; then
                CURRENT="$(tr -d '[:space:]' <"$VERSION_FILE")"
                echo "    no prior v*.*.* tag found; bumping from kotoba/VERSION ($CURRENT)"
            else
                echo "    no prior v*.*.* tag found; seeding at 0.1.0"
                CURRENT="0.1.0"
            fi
        else
            CURRENT="${LATEST_TAG#v}"
            echo "    bumping $BUMP_OR_VERSION: $LATEST_TAG"
        fi
        IFS='.' read -r MAJOR MINOR PATCH <<<"$CURRENT"
        case "$BUMP_OR_VERSION" in
            major) VERSION="$((MAJOR + 1)).0.0" ;;
            minor) VERSION="${MAJOR}.$((MINOR + 1)).0" ;;
            patch) VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
        esac
        ;;
    *)
        if ! [[ "$BUMP_OR_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "error: argument must be major|minor|patch or a semver (e.g. 0.1.0)"
            exit 1
        fi
        VERSION="$BUMP_OR_VERSION"
        ;;
esac

TAG="v$VERSION"

echo "==> releasing $TAG"

for tool in git-cliff gh zip ruby; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "error: $tool is required to cut a release" >&2
        exit 1
    fi
done

if git -C "$REPO_ROOT" rev-parse "$TAG" >/dev/null 2>&1; then
    echo "error: tag $TAG already exists; pick a different bump"
    exit 1
fi

if ! git -C "$REPO_ROOT" diff --quiet HEAD; then
    echo "error: working tree is dirty - commit or stash changes first"
    exit 1
fi

echo "==> generating release notes"
changelog_prepend_unreleased "$REPO_ROOT" "$TAG"
RELEASE_NOTES="$(changelog_release_notes_for_version "$TAG")"

echo "==> bumping kotoba/VERSION"
printf '%s\n' "$VERSION" >"$VERSION_FILE"

if [[ "${RELEASE_SKIP_LINT:-0}" != "1" ]]; then
    echo "==> running lint"
    (cd "$REPO_ROOT" && bun run lint)
else
    echo "==> skipping lint (RELEASE_SKIP_LINT=1)"
fi

echo "==> building integration zips"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"
ruby "$REPO_ROOT/bin/build-integration-zips" "$DIST_DIR"

ZIP_COUNT=$(find "$DIST_DIR" -maxdepth 1 -name 'kotoba-*.zip' | wc -l | tr -d ' ')
if [[ "$ZIP_COUNT" == "0" ]]; then
    echo "error: no integration zips were built in $DIST_DIR"
    exit 1
fi
echo "    built $ZIP_COUNT archives"

echo "==> snapshotting docs"
bash "$REPO_ROOT/bin/snapshot-docs" "$VERSION"

echo "==> verifying docs site build"
bun run docs:build:site

echo "==> committing release metadata"
git -C "$REPO_ROOT" add "$VERSION_FILE" "$(changelog_path)" "docs-versions/v$VERSION"
git -C "$REPO_ROOT" commit -S -m "chore(release): bump version to $VERSION"
git -C "$REPO_ROOT" tag -s "$TAG" -m "$TAG"

echo "==> pushing to origin"
git -C "$REPO_ROOT" push origin main
git -C "$REPO_ROOT" push origin "$TAG"

echo "==> creating github release"
# shellcheck disable=SC2086
gh release create "$TAG" \
    --title "$TAG" \
    --notes "$RELEASE_NOTES" \
    "$DIST_DIR"/kotoba-*.zip

echo "==> done - $TAG released"
