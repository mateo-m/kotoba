#!/usr/bin/env bash
set -euo pipefail

# Shared git-cliff helpers for release.sh and release-notes.sh.

changelog_repo_root() {
    cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

changelog_path() {
    echo "${CHANGELOG_PATH:-$(changelog_repo_root)/CHANGELOG.md}"
}

changelog_collapse_whitespace() {
    local path="$1"
    local tmp
    tmp="$(mktemp)"
    perl -0777 -pe 's/\n{3,}/\n\n/g' "$path" >"$tmp"
    mv "$tmp" "$path"
}

changelog_extract_section() {
    local path="$1"
    local version="$2"
    VERSION="${version#v}" perl -0ne '
        $version = quotemeta($ENV{VERSION});
        if (/^## $version - .*?\n\n(.*?)(?=^## \d+\.\d+\.\d+ - |\z)/ms) {
            print $1;
            exit;
        }
    ' "$path"
}

changelog_format_release_notes() {
    local body="$1"
    printf '## What'"'"'s changed\n\n%s\n' "$body"
}

changelog_prepend_unreleased() {
    local repo_root="$1"
    local version_tag="$2"
    local path
    path="$(changelog_path)"

    if [[ -f "$path" ]]; then
        git-cliff --config "$repo_root/cliff.toml" --unreleased --tag "$version_tag" --prepend "$path"
    else
        git-cliff --config "$repo_root/cliff.toml" --unreleased --tag "$version_tag" >"$path"
    fi
    changelog_collapse_whitespace "$path"
}

changelog_prepend_for_tag() {
    local repo_root="$1"
    local version_tag="$2"
    local path
    path="$(changelog_path)"

    if [[ -f "$path" ]]; then
        git-cliff --config "$repo_root/cliff.toml" --tag "$version_tag" --prepend "$path"
    else
        git-cliff --config "$repo_root/cliff.toml" --tag "$version_tag" >"$path"
    fi
    changelog_collapse_whitespace "$path"
}

changelog_release_notes_for_version() {
    local version_tag="$1"
    local path
    local body
    path="$(changelog_path)"
    body="$(changelog_extract_section "$path" "$version_tag")"

    if [[ -z "${body//[$' \t\r\n']/}" ]]; then
        echo "error: failed to extract $version_tag release notes from $path" >&2
        return 1
    fi

    changelog_format_release_notes "$body"
}
