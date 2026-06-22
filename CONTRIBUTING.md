# Contributing

## Pre-commit Checks

This repository uses lightweight local checks for formatting and linting:

```sh
bin/ruby18 bin/format
bin/ruby18 bin/lint
bin/lint-docker
```

Formatting, Ruby syntax checks, and the unit suite run under Ruby 1.8 to protect runtime compatibility. Dockerfile checks run separately with Docker on the host.

To install hooks with Lefthook:

```sh
bun install
bun run hooks:install
```

If Lefthook is not installed, use the repository fallback hook:

```sh
bin/install-hooks
```

The pre-commit checks format project text files, run Ruby syntax checks, run the unit suite, and validate Dockerfiles when Docker is available.

You can also run the complete pre-commit sequence with:

```sh
bun run precommit
```
