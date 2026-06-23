# Kotoba

Internationalization for RPG Maker XP fan games and Pokemon Essentials projects — JSON catalogs, locale fallbacks, and dialog syntax on Ruby 1.8.

**Documentation:** **[mateo-m.github.io/kotoba](https://mateo-m.github.io/kotoba/)** — install guides, translator handoff, API reference, and tooling.

The site is built with [VitePress](https://vitepress.dev/) from the `docs/` folder in this repository. The README is a landing page only; detailed guides live on the docs site so they stay in one place and update without a new library release.

---

## Choose your path

| If you are… | Start here |
| --- | --- |
| Adding Kotoba to a game with `Game.exe` | [Installing in a game](https://mateo-m.github.io/kotoba/essential/installation) |
| A volunteer translator (spreadsheet) | [For translators](https://mateo-m.github.io/kotoba/translators/) |
| Working from a git clone | [Quick Start](https://mateo-m.github.io/kotoba/essential/quick-start) |
| Something broke during install | [Troubleshooting](https://mateo-m.github.io/kotoba/essential/troubleshooting) |
| Contributing to Kotoba | [CONTRIBUTING.md](CONTRIBUTING.md) · [CI](https://mateo-m.github.io/kotoba/contributors/ci) |

Full outline: [Table of contents](https://mateo-m.github.io/kotoba/table-of-contents)

---

## Install in a game (summary)

1. Download the integration ZIP for your kit from [GitHub Releases](https://github.com/mateo-m/kotoba/releases).
2. Extract into your game folder (next to `Game.exe`). Kotoba ships as a single `kotoba/` directory.
3. Add a `Kotoba` section in **Tools → Script Editor** above `Main`:

```ruby
load "kotoba/boot.rb"
```

Your translation files (for example `Locales/en.json`) live **outside** `kotoba/` — they are game content, not part of the library.

Step-by-step walkthroughs, smoke tests, and ZIP matrix: **[Installing in a game](https://mateo-m.github.io/kotoba/essential/installation)**.

---

## What you get

- Runtime `Kotoba.t` with nested JSON catalogs and locale fallback chains
- Message syntax for variables, plural, and RPG Maker control codes
- Opt-in adapters for bare RGSS and Pokemon Essentials (v16–v21, BES)
- CLI for validation, Essentials/PBS import, and spreadsheet handoff to volunteers

Feature and API details are on the docs site — not duplicated here.

---

## Repository layout

```text
kotoba/           Runtime, adapters, boot script, and samples (shipped in release ZIPs)
docs/             VitePress documentation (source for the website)
tools/            Import, validation, and release packaging
test/             Ruby 1.8 compatibility and fixture tests
bin/              CLI and developer scripts
```

---

## Developing

Requirements: [Bun](https://bun.sh/), Ruby 1.8 (via `bin/ruby18` / Docker), and optionally Docker for legacy image checks.

```sh
git clone https://github.com/mateo-m/kotoba.git
cd kotoba
bun install
bun run hooks:install
bin/ruby18 bin/lint
```

Preview documentation locally:

```sh
bun run docs:dev      # http://localhost:5173/
bun run docs:build    # static output in docs/.vitepress/dist
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for hooks, commits, and optional full-game fixtures. Release and docs deploy notes: [CI](https://mateo-m.github.io/kotoba/contributors/ci).

---

## Contributing

Pull requests are welcome. Run `bin/ruby18 bin/lint` before submitting. For larger changes, open an issue first.

---

## Links

| Resource | URL |
| --- | --- |
| Documentation | https://mateo-m.github.io/kotoba/ |
| Releases | https://github.com/mateo-m/kotoba/releases |
| Roadmap | https://mateo-m.github.io/kotoba/contributors/roadmap |
