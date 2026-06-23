# Kotoba

Internationalization for RPG Maker XP fan games and Pokemon Essentials: JSON catalogs, locale fallbacks, dialog syntax, Ruby 1.8.

**Docs:** [mateo-m.github.io/kotoba](https://mateo-m.github.io/kotoba/) (VitePress, built from `docs/` on push to `main`).

---

## Install in a game

1. Download the integration ZIP for your kit from [GitHub Releases](https://github.com/mateo-m/kotoba/releases).
2. Extract into your game folder (next to `Game.exe`). Kotoba ships as one `kotoba/` directory.
3. In **Tools → Script Editor**, add a `Kotoba` section above `Main`:

```ruby
load "kotoba/boot.rb"
```

Translation files (`Locales/en.json`, etc.) live outside `kotoba/`.

Walkthrough, smoke tests, ZIP matrix: [Installing in a game](https://mateo-m.github.io/kotoba/essential/installation).

Other entry points: [translators](https://mateo-m.github.io/kotoba/translators/) · [quick start (git)](https://mateo-m.github.io/kotoba/essential/quick-start) · [table of contents](https://mateo-m.github.io/kotoba/table-of-contents)

---

## Repository layout

```text
kotoba/           Runtime, adapters, boot script, samples (in release ZIPs)
docs/             VitePress site source
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
