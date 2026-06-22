# Getting Started

This guide starts with a plain Ruby file because that is the easiest way to verify the runtime before putting it inside RPG Maker.

## 1. Create A Catalog

Create `Locales/en.json`:

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

Catalogs are strict JSON. Leaves must be strings, and lookup keys use dots between nested object names.

## 2. Load The Runtime

```ruby
require_relative "runtime/rgss_i18n_core"

RGSSI18n.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"]
  }
end

RGSSI18n.load!
```

## 3. Translate Strings

```ruby
RGSSI18n.t("menu.save")
# => "Save"

RGSSI18n.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
# => "A wild Pikachu appeared!"

RGSSI18n.t("battle.item_count", {"count" => 2})
# => "2 items"
```

`_T` is installed by default:

```ruby
_T("menu.save")
```

## 4. Add Another Locale

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

Update config:

```ruby
RGSSI18n.configure do |config|
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
RGSSI18n.locale = "fr"
RGSSI18n.t("menu.save")
# => "Sauvegarder"
```

## 5. Validate Before Shipping

Run:

```sh
bin/ruby18 bin/rgss-i18n load-test Locales/en.json
bin/ruby18 bin/rgss-i18n validate Locales/en.json Locales/fr.json
```

The first command checks JSON and message syntax. The second checks missing keys, placeholder mismatches, and RPG Maker control-code mismatches.

## Related Guides

- For a plain RPG Maker XP project, read [Bare RGSS Adapter](adapters/bare-rgss.md).
- For Pokemon Essentials, read [Pokemon Essentials Adapter](adapters/pokemon-essentials.md).
- For a custom starter kit, read [Third-Party Adapters](adapters/third-party.md).
