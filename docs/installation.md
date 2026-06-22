# Installing Kotoba In A Game

Game projects should use a **GitHub release integration ZIP**, not a checkout of this repository. Each archive ships the runtime, one adapter target, a sample catalog, and `examples/boot_kotoba.rb`.

Migration and validation commands (`bin/kotoba`) stay in this repository for development and CI.

## Pick A Release ZIP

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

Each ZIP includes `MANIFEST.json` with the bundled `kotoba_version`, adapter name, and file list.

## Install Into The Game Tree

1. Unzip the archive into your game project root (next to `Game.exe`).
2. Confirm these paths exist:
   - `kotoba/`
   - `adapters/`
   - `examples/boot_kotoba.rb`
3. Read `INSTALL.md` inside the archive for adapter-specific notes.

## Boot The Runtime

Edit `examples/boot_kotoba.rb` so `config.catalog_paths` points at your locale JSON files, then load it from your RGSS boot path:

```ruby
load "examples/boot_kotoba.rb"
```

The generated boot script already calls `Kotoba.use_adapter("<adapter>", {"load" => true})` for the ZIP you chose.

A minimal bare-RGSS layout after editing paths:

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

Essentials projects use the matching `essentials_*` adapter file from the same ZIP instead of `bare_rgss`.

## Catalogs

Create `Locales/en.json` (and other locales) using the [catalog format](catalog-format.md). The ZIP includes a small example catalog under `examples/` you can copy or replace.

## Validate Before Shipping

Clone this repository on a modern machine when you need migration tooling:

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

See [Validation CLI](validation-cli.md) and [Pokemon Essentials migration](migration/pokemon-essentials.md) for import commands.

## Developing Kotoba Itself

Contributors work from a git clone with Bun, Docker, and `bun run lint`. See [CI](ci.md) for release cuts with `scripts/release.sh`.
