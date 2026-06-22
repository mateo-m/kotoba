# Contributing

Thanks for helping improve Kotoba.

## Getting Started

Clone the repository:

```sh
git clone <repository-url>
cd kotoba
```

Install tooling and git hooks:

```sh
bun install
bun run hooks:install
```

Run the project checks:

```sh
bin/ruby18 bin/format
bin/ruby18 bin/lint
bin/lint-docker
```

Formatting, Ruby syntax checks, and the unit suite run under Ruby 1.8 to protect runtime compatibility. Dockerfile checks run separately with Docker on the host.

### Optional Local Integration Tests

CI runs the tracked fixture suite only. To smoke-test import commands against a full game on your machine, copy `test/fixtures.local.example.yml` to `test/fixtures.local.yml` and point `essentials_bes_sample` at your local game path. The file stays gitignored.

```sh
cp test/fixtures.local.example.yml test/fixtures.local.yml
```

Tests in `test/local_integration_test.rb` skip automatically when the configured path is missing or unavailable inside Docker.

## Making Changes

1. Create a branch for your change.
2. Keep changes focused and match the existing Ruby 1.8 style.
3. Update or add tests when behavior changes.
4. Run the checks above before opening a pull request.

For larger changes, open an issue first so the approach can be discussed before you invest time in a big diff.

## Git Hooks

This repository uses [Lefthook](https://github.com/evilmartians/lefthook) for git hooks.

Install once:

```sh
bun install
bun run hooks:install
```

You can also run:

```sh
bin/install-hooks
```

On every commit, the tracked `lefthook.yml` runs:

- formatting (`bin/ruby18 bin/format`)
- Ruby 1.8 lint and unit tests (`bin/ruby18 bin/lint`)
- Dockerfile lint (`bin/lint-docker`)

Run the same checks manually with:

```sh
bun run precommit
```

## Pull Requests

Pull requests are welcome.

Please make sure:

- tests pass
- formatting and lint checks pass
- documentation is updated when public behavior changes
- commit messages are clear and scoped to the change

## Documentation

If your change affects public behavior, update the relevant file under `docs/`.

Start from [docs/table-of-contents.md](docs/table-of-contents.md) to find the right page.

## Support

If something is unclear, open an issue with:

- what you were trying to do
- what you expected
- what actually happened
- the command output or error message, if any

## Roadmap

Future work is tracked in [docs/contributors/roadmap.md](docs/contributors/roadmap.md). If you want to pick up a planned item, mention it in an issue first.
