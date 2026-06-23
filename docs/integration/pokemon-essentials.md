# Pokemon Essentials integration

Essentials adapters are compatibility bridges. They let an existing project call `Kotoba` without moving every string in one pass.

**First time installing?** Follow [Installing in a game](/essential/installation). Sample catalog: `kotoba/samples/pokemon_essentials/en.json`.

Download the matching ZIP (`kotoba-essentials-v16.zip` through `v21`, or `kotoba-essentials-bes.zip` for BES forks) from [GitHub Releases](https://github.com/mateo-m/kotoba/releases).

This page covers `_INTL` bridges, catalog shape, and wiring Essentials scripts after Kotoba loads without errors.

Supported targets:

- `essentials_v16`
- `essentials_v17`
- `essentials_v18`
- `essentials_v19`
- `essentials_v20`
- `essentials_v21`
- `essentials_bes`

## Choose The Adapter

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

## Catalog for legacy `_INTL`

Essentials scripts often call:

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

**`_ISPRINTF` example** — catalog:

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

Volunteers translating `battle.wild_appeared` keep `{pokemon}` — see [Placeholders](/translators/placeholders).

## Optional Global Patch

The built-in Essentials adapters currently avoid replacing global `_INTL` at file load time. If you want to route a project through the adapter, add a small project-local script after installing the adapter:

```ruby
def _INTL(*args)
  Kotoba::Adapters::EssentialsV18._INTL(*args)
end

def _ISPRINTF(*args)
  Kotoba::Adapters::EssentialsV18._ISPRINTF(*args)
end
```

Do this only after checking that your Essentials scripts do not depend on custom patched behavior.

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

## v21 Split Messages

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

## BES Bridge And Data Names

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

## Migration Workflow

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

Validation catches missing keys, placeholder mismatches, and RPG Maker control-code mismatches before the game boots.

## Fixture Provenance

Adapter support is tied to compatibility tests and fixture provenance under `test/fixtures/essentials/`. Do not claim support for a new Essentials version until it has a fixture and an acceptance test.
