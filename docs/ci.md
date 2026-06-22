# CI

CI should treat Ruby 1.8 as the compatibility gate.

## Local Equivalent

```sh
bun run lint
```

This runs:

- Ruby 1.8 formatting checks
- Ruby syntax checks
- unit and compatibility tests
- Dockerfile checks

## Documentation Site

The docs are published with [VitePress](https://vitepress.dev/).

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

## GitHub Actions

The checked-in workflow at `.github/workflows/ci.yml` runs after changes to runtime, adapter, tooling, test, Docker, or docs files. The `lint` and `docs` jobs run only when their respective paths change. Use **Run workflow** in Actions for a full manual run.

The lint job runs the same lint command after installing Bun. It expects the legacy Ruby Docker images to be buildable on the runner.

Docs deploy through `.github/workflows/docs.yml` on pushes to `main` when docs-related files change. Use **Run workflow** in Actions for a manual redeploy. In the repository Pages settings, choose **GitHub Actions** as the build source.

## Cross-Version Matrix

For release verification, also run:

```sh
docker run --rm --platform linux/amd64 -v "$PWD":/work -w /work ruby-legacy:1.9.3-p551 ruby -Itest -e 'ARGV.each { |file| load file }' test/**/*_test.rb
docker run --rm -v "$PWD":/work -w /work ruby:3.0 ruby -Itest -e 'ARGV.each { |file| load file }' test/**/*_test.rb
docker run --rm -v "$PWD":/work -w /work ruby:3.1 ruby -Itest -e 'ARGV.each { |file| load file }' test/**/*_test.rb
```

The Ruby 1.8 check remains the one that decides runtime compatibility.
