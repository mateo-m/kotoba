# Pokemon Essentials Integration

The Essentials adapters are compatibility bridges. They help an Essentials project call `Kotoba` without moving every string at once.

Install the matching adapter with a [release integration ZIP](installation.md) (`kotoba-essentials-v16.zip` through `kotoba-essentials-v21.zip`, or `kotoba-essentials-bes.zip` for BES forks). Unzip into your game root and load `examples/boot_kotoba.rb` after pointing `config.catalog_paths` at your catalogs.

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
require File.join(".", "adapters", "essentials_v18")

Kotoba.use_adapter("essentials_v18", {
  "catalog_paths" => {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  },
  "load" => true
})
```

Use the adapter matching your Essentials version. `essentials_v19` and `essentials_v20` are separate modules with the same `_INTL` / `_ISPRINTF` bridge shape.

## Catalog For Legacy `_INTL`

Essentials commonly uses source-English strings:

```ruby
_INTL("A wild {1} appeared!", pokemon.name)
```

The adapter fixtures model this with `source_text`:

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

The bridge turns the source string into a stable key, then evaluates the runtime message.

## Calling The Bridge

The adapter exposes module methods:

```ruby
Kotoba::Adapters::EssentialsV18._INTL("A wild {1} appeared!", "Pikachu")
# => "A wild Pikachu appeared!"
```

`_ISPRINTF` style strings are also bridged:

```ruby
Kotoba::Adapters::EssentialsV18._ISPRINTF("You have {1:d} coins.", 42)
```

Catalog messages should use runtime placeholders:

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

## Stable-Key New Code

For new code, prefer stable runtime keys:

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => pokemon.name})
```

This avoids using the English source sentence as an API.

Common places to use stable keys:

```ruby
pbMessage(Kotoba.t("npc.professor_intro", {"player" => $player.name}))
```

```ruby
commands = [
  Kotoba.t("menu.pokemon"),
  Kotoba.t("menu.bag"),
  Kotoba.t("menu.save")
]
```

```ruby
Kernel.pbMessage(Kotoba.t("items.obtained", {
  "trainer" => $player.name,
  "item" => item_name
}))
```

For plugin code, prefer a namespace helper:

```ruby
plugin_t = Kotoba.namespace("plugins.daycare")
pbMessage(plugin_t.call("egg_ready"))
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

Catalog shape:

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
