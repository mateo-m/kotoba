# Adapters

Adapters are opt-in integration layers. The core runtime does not patch RPG Maker or Pokemon Essentials by default.

## Registry API

The public adapter registry lives in `adapters/registry.rb`:

- `Kotoba.register_adapter(name, adapter)`: register any adapter object that responds to `install(options)`.
- `Kotoba.adapter(name)`: return a registered adapter or `nil`.
- `Kotoba.available_adapters`: list registered adapter names.
- `Kotoba.use_adapter(name, options = nil)`: install a registered adapter.

Unknown adapter names raise `Kotoba::AdapterError`.

## Built-In Adapter Targets

- `bare_rgss`
- `essentials_v16`
- `essentials_v17`
- `essentials_v18`
- `essentials_v19`
- `essentials_v20`
- `essentials_v21`
- `essentials_bes`

Fixture provenance lives under `test/fixtures/essentials/*/SOURCE`.

## Built-In Behavior

`bare_rgss` loads configured catalog paths and translates strings prefixed with `i18n:` through `Kotoba::Adapters::BareRGSS.translate_message`.

`essentials_v16`, `essentials_v17`, `essentials_v18`, `essentials_v19`, and `essentials_v20` provide source-text bridge behavior matching the legacy `_INTL` and `_ISPRINTF` shape. The v19 and v20 adapters are separate modules with the same bridge behavior.

`essentials_v21` models split message-file loading.

`essentials_bes` provides the same `_INTL` and `_ISPRINTF` bridge shape as the v16-v20 adapters, plus data-name helpers for fixture-backed move, item, and ability lookup.

## Writing Your Own

Read [Third-Party Adapters](third-party.md).
