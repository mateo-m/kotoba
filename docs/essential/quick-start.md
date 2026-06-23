# Quick Start

Tutorial: load Kotoba from a git clone.

Fangame with `Game.exe`? Use [Installing in a game](/essential/installation) instead.

## Create a catalog

Add `Locales/en.json`:

```json
{
  "menu": {
    "save": "Save",
    "load": "Load"
  },
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!",
    "item_count": "{count, plural, =0 {No items} one {# item} other {# items}}"
  }
}
```

Catalogs are strict JSON. Leaves must be strings. Lookup keys join nested names with dots. See [Catalog format](/essential/catalog-format).

## Load the runtime

```ruby
require_relative "kotoba/core"

Kotoba.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"]
  }
end

Kotoba.load!
```

## Translate strings

```ruby
Kotoba.t("menu.save")
# => "Save"

Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
# => "A wild Pikachu appeared!"

Kotoba.t("battle.item_count", {"count" => 2})
# => "2 items"
```

`_T` is installed by default:

```ruby
_T("menu.save")
```

## Add another locale

Create `Locales/fr.json`:

```json
{
  "menu": {
    "save": "Sauvegarder",
    "load": "Charger"
  },
  "battle": {
    "wild_appeared": "Un {pokemon} sauvage apparait !",
    "item_count": "{count, plural, =0 {Aucun objet} one {# objet} other {# objets}}"
  }
}
```

Point config at both files:

```ruby
Kotoba.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en", "fr"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  }
end
```

Switch locale:

```ruby
Kotoba.locale = "fr"
Kotoba.t("menu.save")
# => "Sauvegarder"
```

## Validate before you ship

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

`load-test` checks JSON and message syntax. `validate` checks missing keys, placeholder mismatches, and RPG Maker control-code drift.

Plain RGSS: [Bare RGSS](/integration/bare-rgss). Essentials: [Pokemon Essentials](/integration/pokemon-essentials). Custom kit: [Third-party adapters](/integration/third-party).
