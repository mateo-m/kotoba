# RPG Maker i18n

> Ruby internationalization for RPG Maker XP and Pokemon Essentials projects.

RPG Maker i18n is a small Ruby library for loading JSON translation catalogs, resolving locale fallbacks, and evaluating game text at runtime. It is written for Ruby 1.8 compatibility first, because RPG Maker XP and RGSS1 still run on that world.

Use it in bare RGSS projects, Pokemon Essentials games, or custom starter kits through opt-in adapters.

## Installing

### Requirements

- Ruby 1.8 for runtime compatibility checks
- [Bun](https://bun.sh/) for git hooks and local tooling
- Docker, if you want legacy Ruby images or Dockerfile linting

### Add the runtime to a game project

Copy the `runtime/` directory into your project, or clone this repository and reference it from your game scripts.

```ruby
require_relative "runtime/rgss_i18n_core"
```

Create a catalog such as `Locales/en.json`:

```json
{
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  }
}
```

Load it:

```ruby
RGSSI18n.configure do |config|
  config.default_locale = "en"
  config.catalog_paths = {
    "en" => ["Locales/en.json"]
  }
end

RGSSI18n.load!
```

For a full walkthrough, read [Getting Started](docs/getting-started.md).

## Usage

Translate a string:

```ruby
RGSSI18n.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
# => "A wild Pikachu appeared!"
```

Load JSON directly:

```ruby
RGSSI18n.load_json("en", File.open("Locales/en.json", "rb") { |file| file.read })
```

Use the `_T` helper installed by default:

```ruby
_T("menu.save")
```

Validate catalogs before shipping:

```sh
bin/ruby18 bin/rgss-i18n load-test Locales/en.json
bin/ruby18 bin/rgss-i18n validate Locales/en.json Locales/fr.json
```

## Features

- `RGSSI18n.t("namespace.key", vars, options)` lookup with nested JSON catalogs
- Locale fallback chains such as `fr-CA -> fr -> en`
- Strict bundled JSON parser with BOM stripping and unicode escape handling
- Message syntax for variables, `select`, cardinal `plural`, exact plural branches, `#`, and apostrophe escaping
- Validation CLI for load tests, schema checks, cross-locale validation, and import/export
- PBS extraction, Essentials `messages.dat` migration, paired-line import, `Text_english_*` import, map `.rxdata` event text import, and translator handoff packages
- Opt-in adapters for bare RGSS and fixture-backed Pokemon Essentials targets
- Ruby 1.8, 1.9, 3.0, and 3.1 compatibility testing through local Ruby and Docker

## Configuration

Runtime options such as locale defaults, catalog paths, fallback chains, and error policies are configured through `RGSSI18n.configure`.

See:

- [Runtime API](docs/runtime-api.md)
- [Catalog Format](docs/catalog-format.md)
- [Message Syntax](docs/message-syntax.md)

## Developing

Clone the repository and install dependencies:

```sh
git clone <repository-url>
cd rpg-maker-i18n
bun install
bun run hooks:install
```

Run formatting, lint, and tests:

```sh
bin/ruby18 bin/format
bin/ruby18 bin/lint
bin/lint-docker
```

Or run the pre-commit hook sequence:

```sh
bun run precommit
```

Build legacy Ruby Docker images once:

```sh
docker build --platform linux/amd64 \
  --build-arg RUBY_MAJOR=1.8 \
  --build-arg RUBY_VERSION=1.8.7-p374 \
  -t ruby-legacy:1.8.7-p374 \
  -f docker/ruby-legacy/Dockerfile .

docker build --platform linux/amd64 \
  --build-arg RUBY_MAJOR=1.9 \
  --build-arg RUBY_VERSION=1.9.3-p551 \
  -t ruby-legacy:1.9.3-p551 \
  -f docker/ruby-legacy/Dockerfile .
```

See [Compatibility](docs/compatibility.md), [CI](docs/ci.md), and [docker/README.md](docker/README.md) for more detail.

## Contributing

Pull requests are welcome. For larger changes, open an issue first so the scope can be discussed.

Please run the local checks before submitting changes. Full setup and hook details are in [CONTRIBUTING.md](CONTRIBUTING.md).

## Documentation

Published docs are built with VitePress and deployed to GitHub Pages on pushes to `main`.

Preview locally:

```sh
bun run docs:dev
```

- [Documentation site](docs/index.md) (source in `docs/`)
- [Getting Started](docs/getting-started.md)
- [Bare RGSS integration](docs/adapters/bare-rgss.md)
- [Pokemon Essentials integration](docs/adapters/pokemon-essentials.md)
- [Third-party adapters](docs/adapters/third-party.md)
- [Validation CLI](docs/validation-cli.md)
- [Roadmap](docs/roadmap.md)

## Roadmap

Project planning and future work live in [docs/roadmap.md](docs/roadmap.md).
