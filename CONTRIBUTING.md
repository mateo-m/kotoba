# Contributing

## Getting started

```sh
git clone <repository-url>
cd kotoba
bun install
bun run hooks:install
bin/ruby18 bin/format
bin/ruby18 bin/lint
bin/lint-docker
```

Formatting, syntax checks, and the unit suite run under Ruby 1.8. Dockerfile checks need Docker on the host.

### Optional local integration tests

CI runs the tracked fixture suite only. For import smoke tests against a full game, copy `test/fixtures.local.example.yml` to `test/fixtures.local.yml` and set `essentials_bes_sample`. Gitignored.

```sh
cp test/fixtures.local.example.yml test/fixtures.local.yml
```

`test/local_integration_test.rb` skips when the path is missing or unavailable in Docker.

## Making changes

1. Branch for your change.
2. Match existing Ruby 1.8 style.
3. Add or update tests when behavior changes.
4. Run the checks above before opening a PR.

For larger changes, open an issue first.

## Git hooks

[Lefthook](https://github.com/evilmartians/lefthook). Install once with `bun run hooks:install` or `bin/install-hooks`.

On every commit (`lefthook.yml`):

- `bin/ruby18 bin/format`
- `bin/ruby18 bin/lint`
- `bin/lint-docker`

Manual: `bun run precommit`

## Pull requests

- tests pass
- format and lint pass
- docs updated when public behavior changes
- clear, scoped commit messages

## Documentation

Public behavior changes → update the matching page under `docs/`. Preview with `bun run docs:dev`.

## Support

Open an issue with: what you tried, what you expected, what happened, and command output if any. For larger planned work, discuss in an issue before starting.
