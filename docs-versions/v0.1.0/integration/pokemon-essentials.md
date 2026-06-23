# Pokemon Essentials integration

Essentials adapters bridge existing `_INTL` calls so you can adopt Kotoba without moving every string at once.

Install: [Installing in a game](/essential/installation). Sample: `kotoba/samples/pokemon_essentials/en.json`.

ZIP (`kotoba-essentials-v16.zip` through `v21`, or `kotoba-essentials-bes.zip`) from [GitHub Releases](https://github.com/mateo-m/kotoba/releases).

Supported targets:

- `essentials_v16`
- `essentials_v17`
- `essentials_v18`
- `essentials_v19`
- `essentials_v20`
- `essentials_v21`
- `essentials_bes`

## Choose the adapter

Your release ZIP’s `kotoba/boot.rb` already `require`s the matching adapter file and calls `Kotoba.use_adapter`. Edit that file for `catalog_paths` and locale lists ([Installing in a game §5](/essential/installation#_5-your-own-translations)).

Use the snippet below only for a custom boot layout, or when reading what the generated `boot.rb` contains:

```ruby
require File.join(".", "kotoba", "core")
require File.join(".", "kotoba", "adapters", "essentials_v18")

Kotoba.use_adapter("essentials_v18", {
  "catalog_paths" => {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  },
  "load" => true
})
```

Use the adapter matching your Essentials version. `essentials_v19` and `essentials_v20` are separate modules with the same `_INTL` / `_ISPRINTF` bridge shape.

## `source_text` vs stable keys

| Situation | Approach |
| --- | --- |
| Existing `_INTL("English sentence", …)` still in scripts | `source_text` map in `Locales/en.json` + adapter bridge |
| New or refactored scripts | `Kotoba.t("battle.wild_appeared", {…})` with stable keys |

## Catalog for legacy `_INTL`

Essentials scripts call:

```ruby
_INTL("A wild {1} appeared!", pokemon.name)
```

**Catalog** (`Locales/en.json`):

```json
{
  "source_text": {
    "A wild {1} appeared!": "battle.wild_appeared"
  },
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  }
}
```

The bridge maps the English source string to a stable key, then evaluates the catalog message.

**Bridge call and result:**

```ruby
Kotoba::Adapters::EssentialsV18._INTL("A wild {1} appeared!", "Pikachu")
# => "A wild Pikachu appeared!"
```

### `_ISPRINTF` example

Catalog:

```json
{
  "source_text": {
    "You have {1:d} coins.": "ui.coins"
  },
  "ui": {
    "coins": "You have {count} coins."
  }
}
```

```ruby
Kotoba::Adapters::EssentialsV18._ISPRINTF("You have {1:d} coins.", 42)
# => "You have 42 coins."
```

Volunteers translating `battle.wild_appeared` keep `{pokemon}`. See [Placeholders](/translators/placeholders).

## Optional global patch

The built-in Essentials adapters do not replace global `_INTL` at file load time. Your ZIP’s `kotoba/boot.rb` loads the adapter; existing game scripts still call `_INTL` until you route them through the bridge (catalog + `source_text`) or add a global patch.

Add a project-local Script Editor section **after** `kotoba/boot.rb` loads, only if `_INTL` is not already reaching the adapter and you have checked for custom Essentials patches:

```ruby
def _INTL(*args)
  Kotoba::Adapters::EssentialsV18._INTL(*args)
end

def _ISPRINTF(*args)
  Kotoba::Adapters::EssentialsV18._ISPRINTF(*args)
end
```

Replace `EssentialsV18` with your adapter module. Prefer catalog + `source_text` over a global patch when you can.

## Stable-key new code

Prefer stable keys instead of English source sentences as API.

**Catalog:**

```json
{
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  },
  "menu": {
    "pokemon": "Pokémon",
    "bag": "Bag",
    "save": "Save"
  }
}
```

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => pokemon.name})
# => "A wild Pikachu appeared!"

pbMessage(Kotoba.t("menu.save"))
# => shows "Save"
```

## v21 split messages

The v21 adapter can load split message files through normal `catalog_paths`:

```ruby
Kotoba.use_adapter("essentials_v21", {
  "catalog_paths" => {
    "en" => [
      "Locales/en/messages_core.json",
      "Locales/en/messages_game.json"
    ]
  },
  "load" => true
})
```

## BES bridge and data names

The BES adapter supports the same `_INTL` and `_ISPRINTF` bridge as the v16-v20 adapters:

```ruby
Kotoba.use_adapter("essentials_bes", {
  "catalog_paths" => {"en" => ["Locales/en.json"]},
  "load" => true
})

Kotoba::Adapters::EssentialsBES._INTL("A wild {1} appeared!", "Pikachu")
Kotoba::Adapters::EssentialsBES._ISPRINTF("You have {1:d} coins.", 42)
```

Use `install_global: true` only when you intentionally want project-wide `_INTL` routing. See [Optional Global Patch](#optional-global-patch).

The adapter also exposes small data-name helpers:

```ruby
Kotoba::Adapters::EssentialsBES.move_name("thunderbolt")
Kotoba::Adapters::EssentialsBES.item_name("potion")
Kotoba::Adapters::EssentialsBES.ability_name("overgrow")
```

**Catalog:**

```json
{
  "data": {
    "moves": {
      "thunderbolt": {
        "name": "Thunderbolt"
      }
    }
  }
}
```

```ruby
Kotoba::Adapters::EssentialsBES.move_name("thunderbolt")
# => "Thunderbolt"
```

## Migration workflow

1. Add the runtime and adapter.
2. Add a source locale JSON catalog.
3. Add `source_text` mappings for existing `_INTL` strings.
4. Validate the source catalog.
5. Add translated locale catalogs.
6. Validate translated catalogs against the source catalog.
7. Convert new code to stable `Kotoba.t` keys over time.

## Validation

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

Validation catches missing keys, placeholder mismatches, and RPG Maker control-code mismatches before playtest. Copy validated `Locales/*.json` into the game folder. Commands: [Validation CLI](/tooling/validation-cli).
