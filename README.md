# Kotoba

JSON catalogs and locale fallbacks for RPG Maker XP fan games and Pokemon Essentials. Ruby 1.8 / RGSS1.

**Docs:** [mateo-m.github.io/kotoba](https://mateo-m.github.io/kotoba/) · **License:** [MIT](LICENSE)

---

## Install in a game

1. Download the integration ZIP for your kit from [GitHub Releases](https://github.com/mateo-m/kotoba/releases).
2. Extract into your game folder (next to `Game.exe`).
3. In **Tools → Script Editor**, add a `Kotoba` section above `Main` and paste:

### Pokemon Essentials

```ruby
load "kotoba/samples/script_editor/essentials_smoke_test.rb"
```

Playtest (F12). You should see `A wild Pikachu appeared!` from the sample catalog.

### Bare RPG Maker XP

```ruby
load "kotoba/samples/script_editor/bare_rgss_smoke_test.rb"
```

You should see `Kotoba says: Save`.

When the smoke test passes, switch Script Editor to `load "kotoba/boot.rb"` and point `kotoba/boot.rb` at your own `Locales/*.json` files.

Full walkthrough: [Installing in a game](https://mateo-m.github.io/kotoba/essential/installation). Essentials bridge: [Pokemon Essentials](https://mateo-m.github.io/kotoba/integration/pokemon-essentials). Translators: [handoff guide](https://mateo-m.github.io/kotoba/translators/). Git clone: [Quick Start](https://mateo-m.github.io/kotoba/essential/quick-start).

---

## Repository layout

```text
kotoba/           Runtime, adapters, boot script, samples (in release ZIPs)
docs/             Published documentation source
tools/            Import, validation, release packaging
test/             Ruby 1.8 tests
bin/              CLI and developer scripts
```

---

## Developing

Requirements: [Bun](https://bun.sh/), Ruby 1.8 (`bin/ruby18` / Docker), optional Docker for legacy image checks.

```sh
git clone https://github.com/mateo-m/kotoba.git
cd kotoba
bun install
bun run hooks:install
bin/ruby18 bin/lint
```

Docs locally: `bun run docs:dev` → http://localhost:5173/

See [CONTRIBUTING.md](CONTRIBUTING.md) for hooks, commits, and optional full-game fixtures. CI and releases: [contributors/ci](https://mateo-m.github.io/kotoba/contributors/ci).
