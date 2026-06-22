# Installing in a game

Use a **GitHub release integration ZIP** for shipped games. Each archive includes the runtime, one adapter, a sample catalog, and `examples/boot_kotoba.rb`.

`bin/kotoba` migration and validation commands live in this repository — clone it when you need those tools on a modern machine.

## Pick a release ZIP

Download the archive that matches your project from [GitHub Releases](https://github.com/mateo-m/kotoba/releases):

| ZIP | Adapter | Typical project |
| --- | --- | --- |
| `kotoba-bare-rgss.zip` | `bare_rgss` | Plain RPG Maker XP / RGSS |
| `kotoba-essentials-bes.zip` | `essentials_bes` | Essentials BES forks |
| `kotoba-essentials-v16.zip` | `essentials_v16` | Pokemon Essentials v16 |
| `kotoba-essentials-v17.zip` | `essentials_v17` | Pokemon Essentials v17 |
| `kotoba-essentials-v18.zip` | `essentials_v18` | Pokemon Essentials v18 |
| `kotoba-essentials-v19.zip` | `essentials_v19` | Pokemon Essentials v19 |
| `kotoba-essentials-v20.zip` | `essentials_v20` | Pokemon Essentials v20 |
| `kotoba-essentials-v21.zip` | `essentials_v21` | Pokemon Essentials v21 |

`MANIFEST.json` inside each ZIP lists `kotoba_version`, the adapter name, and bundled files.

## Install into the game tree

1. Unzip the archive into your game root (next to `Game.exe`).
2. Confirm `kotoba/`, `adapters/`, and `examples/boot_kotoba.rb` exist.
3. Read `INSTALL.md` in the archive for adapter-specific notes.

## Boot the runtime

Point `config.catalog_paths` at your locale JSON, then load the boot script from your RGSS boot path:

```ruby
load "examples/boot_kotoba.rb"
```

The generated script already calls `Kotoba.use_adapter("<adapter>", {"load" => true})` for the ZIP you chose.

Minimal bare-RGSS boot after editing paths:

```ruby
require File.join(".", "kotoba", "core")
require File.join(".", "adapters", "bare_rgss")

Kotoba.configure do |config|
  config.default_locale = "en"
  config.catalog_paths = {
    "en" => ["Locales/en.json"]
  }
end

Kotoba.use_adapter("bare_rgss", {"load" => true})
```

Essentials projects load the matching `essentials_*` adapter from the same ZIP instead of `bare_rgss`.

## Catalogs

Create `Locales/en.json` (and other locales) using the [catalog format](/essential/catalog-format). Each ZIP ships a small example under `examples/` you can copy or replace.

## Validate before you ship

On a dev machine with this repo cloned:

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

Import commands and Essentials migration steps are in [Validation CLI](/tooling/validation-cli) and [Essentials migration](/integration/pokemon-essentials-migration).

## Developing Kotoba itself

Contributors work from a git clone with Bun, Docker, and `bun run lint`. See [CI](/contributors/ci) for release cuts with `scripts/release.sh`.
