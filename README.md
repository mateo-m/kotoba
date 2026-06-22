# RPG Maker i18n

A small Ruby internationalization runtime for RPG Maker-era projects.

The runtime is written for Ruby 1.8 compatibility first. That matters because RPG Maker XP and RGSS1 live in that world, and code that passes on modern Ruby can still be useless in-game if it depends on newer syntax or libraries.

## What Works Today

- `RGSSI18n.t("namespace.key", vars, options)` lookup.
- Nested JSON catalogs loaded directly at runtime.
- Locale fallback chains such as `fr-CA -> fr -> en`.
- A strict bundled JSON parser, including BOM stripping and unicode escape handling.
- A small message syntax: static text, named variables, `select`, cardinal `plural`, exact plural branches, `#`, and apostrophe escaping.
- Validator, flat-key, pseudolocalization, SimpleLocalize, XLIFF, and PO tooling.
- PBS text extraction, Essentials `messages.dat` migration, paired-line import, validation reports, and translator handoff packages.
- Opt-in adapters for bare RGSS and fixture-backed Essentials targets.
- Ruby 1.8, 1.9, 3.0, and 3.1 test coverage through local Ruby and Docker.
- Generic locally built Docker images for Ruby `1.8.7-p374` and `1.9.3-p551`.

Project planning lives in [`docs/roadmap.md`](docs/roadmap.md).

## Quick Start

Load the runtime:

```ruby
require_relative "runtime/rgss_i18n_core"
```

Register catalogs:

```ruby
RGSSI18n.load_hash("en", {
  "battle" => {
    "wild_appeared" => "A wild {pokemon} appeared!"
  }
})

RGSSI18n.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
# => "A wild Pikachu appeared!"
```

Load JSON directly:

```ruby
RGSSI18n.load_json("en", File.open("Locales/en.json", "rb") { |file| file.read })
```

## Development

Build the Ruby 1.8 image once:

```sh
docker build --platform linux/amd64 \
  --build-arg RUBY_MAJOR=1.8 \
  --build-arg RUBY_VERSION=1.8.7-p374 \
  -t ruby-legacy:1.8.7-p374 \
  -f docker/ruby-legacy/Dockerfile .
```

Run the Ruby compatibility checks:

```sh
bin/ruby18 bin/lint
```

Run all local checks:

```sh
bun install
bun run lint
```

Install pre-commit hooks:

```sh
bun run hooks:install
```

## Documentation

- `docs/index.md`: documentation index.
- `docs/getting-started.md`: first catalog and translation.
- `docs/runtime-api.md`: public runtime API.
- `docs/catalog-format.md`: catalog structure and key conventions.
- `docs/message-syntax.md`: supported message syntax.
- `docs/adapters/bare-rgss.md`: plain RGSS integration.
- `docs/adapters/pokemon-essentials.md`: Pokemon Essentials integration.
- `docs/adapters/third-party.md`: guide for writing external adapters.
- `docs/validation-cli.md`: validation and import/export commands.
- `docs/compatibility.md`: Ruby and Docker compatibility notes.
- `docs/ci.md`: CI and release verification notes.
- `docs/roadmap.md`: current status and project planning.
