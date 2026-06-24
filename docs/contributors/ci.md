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

The docs are published with [Docusaurus](https://docusaurus.io/).

GitHub Pages serves project sites at `https://<user>.github.io/<repository>/`. The docs base path comes from the repository name:

- CI sets `DOCUSAURUS_BASE` and `DOCUSAURUS_REPOSITORY_NAME` from `github.event.repository.name`.
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

### Documentation versioning

`https://mateo-m.github.io/kotoba/` serves **latest** (`main`). Each release freezes `docs/` into `versioned_docs/version-v<semver>/` and publishes that edition at `…/v<semver>/…`.

| Piece | Behavior |
| --- | --- |
| **Doc edition** | `bunx docusaurus docs:version v<semver>` during `scripts/release.sh` |
| **Site build** | `bun run docs:build` builds latest + every version in `versions.json` |
| **ZIP `MANIFEST.json`** | `docs_install_url` → `…/v<version>/essential/installation` |
| **Version switcher** | Docusaurus docs version dropdown in the navbar |
| **Footer** | Shows `kotoba/VERSION` from the repository |

Doc version matches `kotoba/VERSION`. No separate docs semver.

To redeploy an old doc edition from a git tag, check out the tag and run `bun run docs:build`, then push the output to the `gh-pages` branch (or run the Docs workflow from that ref).

## GitHub Actions

The checked-in workflow at `.github/workflows/ci.yml` runs after changes to runtime, adapter, tooling, test, Docker, or docs files. The `lint` and `docs` jobs run only when their respective paths change. Use **Run workflow** in Actions for a full manual run.

The lint job runs the same lint command after installing Bun. It expects the legacy Ruby Docker images to be buildable on the runner.

Docs deploy through `.github/workflows/docs.yml` on pushes to `main` when docs-related files change. The workflow pushes the built site to the `gh-pages` branch. In the repository Pages settings, choose **Deploy from a branch** and set the branch to `gh-pages` / root.

## Releases

Cut a release locally with `scripts/release.sh`:

```sh
brew install git-cliff gh   # once
scripts/release.sh 0.1.0    # first release; later: patch | minor | major
```

The script:

1. Prepends git-cliff notes to `CHANGELOG.md` and bumps `kotoba/VERSION`. Only commits that touch library paths listed in `cliff.toml` are included.
2. Runs `bun run lint` (skip with `RELEASE_SKIP_LINT=1`).
3. Builds integration ZIPs into `dist/`.
4. Runs `docusaurus docs:version` to freeze the doc edition, verifies the site build, then creates a signed commit and tag, pushes `main` + the tag.
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
