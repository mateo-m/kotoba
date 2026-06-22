# Compatibility

Ruby 1.8 is the compatibility gate. Modern Ruby runs are useful, but they do not prove RPG Maker XP/RGSS compatibility.

## Tested Rubies

Current test coverage has been run against:

- Ruby `1.8.7-p374`
- Ruby `1.9.3-p551`
- Ruby `3.0`
- Ruby `3.1`

Ruby 1.8 and 1.9 use local Docker images.

## Legacy Ruby Images

Build Ruby 1.8:

```sh
docker build --platform linux/amd64 \
  --build-arg RUBY_MAJOR=1.8 \
  --build-arg RUBY_VERSION=1.8.7-p374 \
  -t ruby-legacy:1.8.7-p374 \
  -f docker/ruby-legacy/Dockerfile .
```

Build Ruby 1.9:

```sh
docker build --platform linux/amd64 \
  --build-arg RUBY_MAJOR=1.9 \
  --build-arg RUBY_VERSION=1.9.3-p551 \
  -t ruby-legacy:1.9.3-p551 \
  -f docker/ruby-legacy/Dockerfile .
```

## Running Checks

Ruby 1.8 checks:

```sh
bin/ruby18 bin/lint
```

Dockerfile checks:

```sh
bin/lint-docker
```

Full Bun script:

```sh
bun run lint
```

## Runtime Rules

Avoid Ruby features newer than 1.8 in runtime and adapter files:

- keyword arguments
- safe navigation
- refinements
- frozen-string comments
- pattern matching
- `Encoding`
- standard-library `json`
- modern Enumerable conveniences unless deliberately polyfilled

Tests and scripts also stay conservative because they run under Ruby 1.8 during linting.
