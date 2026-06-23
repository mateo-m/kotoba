# Integration

Adapters connect Kotoba to RPG Maker XP, Pokemon Essentials, or your own engine. The core runtime does not patch game code by default — you opt in with `Kotoba.use_adapter`.

For shipped games, install an adapter through a [release integration ZIP](/essential/installation). Do not copy adapter files from this repository by hand.

## Registry API

The public registry lives in `kotoba/adapters/registry.rb`:

- `Kotoba.register_adapter(name, adapter)` — register an object that responds to `install(options)`
- `Kotoba.adapter(name)` — look up a registered adapter, or `nil`
- `Kotoba.available_adapters` — list registered names
- `Kotoba.use_adapter(name, options = nil)` — install a registered adapter

Unknown names raise `Kotoba::AdapterError`.

## Built-in targets

| Name | Project |
| --- | --- |
| `bare_rgss` | Plain RPG Maker XP / RGSS |
| `essentials_v16` … `essentials_v21` | Pokemon Essentials by version |
| `essentials_bes` | Essentials BES forks |

Fixture provenance is under `test/fixtures/essentials/*/SOURCE`.

## What each adapter does

**`bare_rgss`** loads configured catalogs and translates strings prefixed with `kotoba:` through `Kotoba::Adapters::BareRGSS.translate_message`.

**`essentials_v16`–`essentials_v20`** bridge legacy `_INTL` and `_ISPRINTF` calls through `source_text` mappings. v19 and v20 are separate modules with the same bridge shape.

**`essentials_v21`** models split message-file loading.

**`essentials_bes`** matches the v16–v20 bridge and adds data-name helpers for moves, items, and abilities.

## Custom adapters

See [Third-party adapters](/integration/third-party) to register your own `install` hook.
