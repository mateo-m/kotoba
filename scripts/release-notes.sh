#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=scripts/changelog-release.sh
source "$REPO_ROOT/scripts/changelog-release.sh"

usage() {
    echo "usage: $0 <tag>"
    echo "  tag   existing release tag (e.g. v0.1.0)"
    echo ""
    echo "Prepends that tag's entry to CHANGELOG.md and prints GitHub release notes."
    echo "Used by CI when a tag already exists on the remote."
    exit 1
}

[[ $# -eq 1 ]] || usage
VERSION="$1"

if ! command -v git-cliff >/dev/null 2>&1; then
    echo "error: git-cliff is required to generate release notes" >&2
    exit 1
fi

if ! git -C "$REPO_ROOT" rev-parse "$VERSION" >/dev/null 2>&1; then
    echo "error: tag $VERSION does not exist" >&2
    exit 1
fi

changelog_prepend_for_tag "$REPO_ROOT" "$VERSION"
changelog_release_notes_for_version "$VERSION"
