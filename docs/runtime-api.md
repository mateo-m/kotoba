# Runtime API

The public runtime namespace is `Kotoba`. Runtime code is Ruby 1.8-compatible, so examples avoid keyword arguments, safe navigation, and newer standard library assumptions.

## Setup

```ruby
require_relative "kotoba/core"

Kotoba.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en", "fr", "fr-CA"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  }
end
```

## Configuration

Locale and catalog fields:

- `source_locale`: authoring source locale. Default: `"en"`.
- `default_locale`: final fallback locale. Default: `"en"`.
- `available_locales`: locales known to menus and tools.
- `locale_names`: display names keyed by locale.
- `catalog_paths`: locale-to-file mapping used by `load!`.
- `catalog_discovery_paths`: directories scanned for `<locale>.json` and `<locale>/*.json`.
- `fallbacks`: explicit fallback chains. Use `"default"` for the shared fallback tail.

Missing translation fields:

- `strict`: raise `Kotoba::MissingTranslationError` for missing keys.
- `diagnostics`: append missing keys to `diagnostics_file`.
- `diagnostics_file`: missing-key log path.
- `show_missing_keys`: render `"translation missing: key"`.
- `missing_handler`: callable receiving `key, locale`.

Runtime limits and policies:

- `warn_catalog_bytes`: warn threshold for one catalog.
- `max_catalog_bytes`: hard limit for one catalog.
- `max_loaded_catalog_bytes`: hard limit across loaded catalogs.
- `max_json_depth`: JSON nesting limit.
- `max_message_depth`: message nesting limit.
- `duplicate_key_policy`: `"override"`, `"warn"`, or `"error"`.
- `missing_variable_policy`: `"keep"`, `"empty"`, or `"error"`.
- `warning_handler`: callable receiving warning text.
- `locale_change_handler`: callable receiving `old_locale, new_locale`.

Integration fields:

- `global_helper`: installs `_T`. Default: `true`.
- `i18n_alias`: installs `I18n = Kotoba` when no `I18n` constant exists.
- `file_loader`: callable receiving a path and returning file contents.

## Lifecycle

- `Kotoba.reset!`: reset config, locale, catalogs, and helpers.
- `Kotoba.config`: return the config object.
- `Kotoba.configure { |config| ... }`: mutate config and return it.
- `Kotoba.locale`: return the active normalized locale.
- `Kotoba.locale = "fr_CA"`: normalize, store, and load the locale chain.
- `Kotoba.available_locales`: return normalized configured locales.
- `Kotoba.normalize_locale(value)`: normalize locale IDs, e.g. `"pt_br"` to `"pt-BR"`.
- `Kotoba.fallback_chain(locale)`: return lookup order for a locale.
- `Kotoba.on_locale_change(callback)`: register a locale-change callback.
- `Kotoba.source_text_key(source_text, options = nil)`: look up a literal source-text mapping without splitting the source sentence on dots.

Locale-change handlers fire only when the normalized locale actually changes:

```ruby
Kotoba.on_locale_change(lambda do |old_locale, new_locale|
  # refresh windows or menus here
end)
```

## Loading Catalogs

Load a Ruby hash:

```ruby
Kotoba.load_hash("en", {
  "menu" => {
    "save" => "Save"
  }
})
```

Load JSON source:

```ruby
source = File.open("Locales/en.json", "rb") { |file| file.read }
Kotoba.load_json("en", source)
```

Load configured files:

```ruby
Kotoba.load!
```

Reload configured files:

```ruby
Kotoba.reload!
```

`load_path(locale, path)` reads one JSON file. If `config.file_loader` is set, the loader is used instead of `File.open`.

Catalog discovery can reduce boot config for folder-based projects:

```ruby
Kotoba.configure do |config|
  config.catalog_discovery_paths = ["Locales"]
end
```

For locale `en`, the runtime discovers:

```text
Locales/en.json
Locales/en/*.json
```

## Translating

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
# => "A wild Pikachu appeared!"
```

Supported options:

- `"locale"`: override the active locale.
- `"default"`: fallback message if the key is missing.

```ruby
Kotoba.t(
  "battle.wild_appeared",
  {"pokemon" => "Pikachu"},
  {"locale" => "fr", "default" => "A wild {pokemon} appeared!"}
)
```

Namespaces are useful inside scripts that repeatedly read the same subtree:

```ruby
battle_t = Kotoba.namespace("battle")
battle_t.call("wild_appeared", {"pokemon" => "Pikachu"})
```

Global helper:

```ruby
_T("menu.save")
```

Source-text mappings are looked up directly under the `source_text` catalog object:

```ruby
Kotoba.source_text_key("Hello. {1}")
# => "legacy.line_0001"
```

This is used by Essentials migration adapters because source strings often contain periods and cannot safely be treated as dot-separated lookup paths.

## Errors

- `Kotoba::MissingTranslationError`: raised for missing keys when `strict` is true.
- `Kotoba::CatalogError`: invalid catalog root/leaves, duplicate keys configured as errors, or catalog size limits.
- `Kotoba::MessageParseError`: invalid message syntax during catalog load.
- `Kotoba::MessageEvaluationError`: invalid plural variables or missing variables configured as errors.

## Boundary

The core runtime does not know about RPG Maker maps, Pokemon Essentials, PBS files, or editor internals. Those belong in adapters and tooling.
