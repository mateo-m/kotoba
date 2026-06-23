# CI

CI should treat Ruby 1.8 as the compatibility gate.

## Local equivalent

```sh
bun run lint
```

This runs:

- Ruby 1.8 formatting checks
- Ruby syntax checks
- unit and compatibility tests
- Dockerfile checks

## Documentation site

The docs are published with [VitePress](https://vitepress.dev/).

GitHub Pages serves project sites at `https://<user>.github.io/<repository>/`. The docs base path comes from the repository name:

- CI sets `VITEPRESS_BASE` and `VITEPRESS_REPOSITORY_NAME` from `github.event.repository.name`.
- Local builds resolve the same value from `git remote get-url origin` when those variables are unset.
- `bun run docs:dev` uses `/` so local navigation stays at the dev-server root.

After renaming the GitHub repository, run the **Docs** workflow once so Pages picks up the new base path.

Preview locally:

```sh
bun install
bun run docs:dev
```

Build and preview the static output:

```sh
bun run docs:build
bun run docs:preview
```

### Documentation versioning (policy)

**Today (pre–`v0.1.0`):** docs are **not versioned**. Every push to `main` updates a single rolling site at `https://mateo-m.github.io/kotoba/`. Integration ZIPs link to the unversioned install page via `docs_install_url` in `MANIFEST.json`.

**First public release:** `v0.1.0`. Library, integration ZIPs, and docs share one version number (`kotoba/VERSION` = git tag without `v`).

**At `v0.1.0` (implement with the release, not before):**

| Piece | Behavior |
| --- | --- |
| **Doc snapshot** | Freeze `docs/` into a versioned tree (e.g. `docs-versions/v0.1.0/` or build from tag `v0.1.0`) |
| **Site URLs** | `…/kotoba/` = latest (`main`); `…/kotoba/v0.1.0/…` = frozen install guide for that ZIP |
| **ZIP `MANIFEST.json`** | `docs_install_url` pinned to `…/v0.1.0/essential/installation` |
| **Version switcher** | Nav dropdown: `latest` · `v0.1.0` · … |
| **No backfill** | Do not publish doc trees for pre-release tags or layouts that never shipped |

**After `v0.1.0`:** each `scripts/release.sh` tag adds a new frozen doc tree. Improving docs on `main` updates `latest` only; shipped ZIPs keep their pinned URL.

Doc version matches `kotoba/VERSION`. No separate docs semver.

Implementation checklist (for the `v0.1.0` release PR):

1. Add doc snapshot step to `scripts/release.sh`.
2. Extend `.github/workflows/docs.yml` to build `latest` + versioned folders.
3. Pin `docs_install_url` in `tools/integration_release.rb` using `KOTOBA_DOCS_URL` + `/v{version}/`.
4. Add VitePress version switcher (e.g. `@viteplus/versions` or equivalent).
5. Show `kotoba/VERSION` in the docs footer.

Until then, this policy is documentation-only; rolling latest remains intentional.

## GitHub Actions

The checked-in workflow at `.github/workflows/ci.yml` runs after changes to runtime, adapter, tooling, test, Docker, or docs files. The `lint` and `docs` jobs run only when their respective paths change. Use **Run workflow** in Actions for a full manual run.

The lint job runs the same lint command after installing Bun. It expects the legacy Ruby Docker images to be buildable on the runner.

Docs deploy through `.github/workflows/docs.yml` on pushes to `main` when docs-related files change. Use **Run workflow** in Actions for a manual redeploy. In the repository Pages settings, choose **GitHub Actions** as the build source.

## Releases

**First public release:** `v0.1.0`. Pre-release work on `main` uses `kotoba/VERSION` `0.1.0` and an `Unreleased` changelog section until `scripts/release.sh` cuts the tag.

Cut a release locally with `scripts/release.sh`:

```sh
brew install git-cliff gh   # once
scripts/release.sh 0.1.0    # first release; later: patch | minor | major
```

The script:

1. Prepends git-cliff notes to `CHANGELOG.md` and bumps `kotoba/VERSION`.
2. Runs `bun run lint` (skip with `RELEASE_SKIP_LINT=1`).
3. Builds integration ZIPs into `dist/`.
4. Creates a signed commit and tag, pushes `main` + the tag.
5. Runs `gh release create` with the ZIPs and a **What's changed** body.

Integration ZIPs ship a minimal `INSTALL.md` (adapter facts + link to the online install guide). Full install documentation lives in `docs/essential/installation.md` and deploys via the Docs workflow, not through library releases.

Preview notes before cutting:

```sh
git-cliff --config cliff.toml --unreleased --tag v0.1.0
```

To rebuild assets or refresh notes for an existing tag, run the **Release** workflow manually in GitHub Actions and pass the tag name.

## Cross-version matrix

For release verification, also run:

```sh
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ruby-legacy:1.9.3-p551 ruby -Itest -e 'ARGV.each { |file| load file }' test/**/*_test.rb
docker run --rm -v "$PWD":/work -w /work ruby:3.0 ruby -Itest -e 'ARGV.each { |file| load file }' test/**/*_test.rb
docker run --rm -v "$PWD":/work -w /work ruby:3.1 ruby -Itest -e 'ARGV.each { |file| load file }' test/**/*_test.rb
```

The Ruby 1.8 check remains the one that decides runtime compatibility.
