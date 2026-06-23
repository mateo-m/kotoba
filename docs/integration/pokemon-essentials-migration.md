# Essentials migration

How-to: move from source-English `_INTL` to stable JSON catalogs.

Essentials adapters bridge legacy `_INTL` calls. Adopt stable JSON catalogs one area at a time.

## The problem with source-English keys

Legacy Essentials text passes the English sentence straight into `_INTL`:

```ruby
_INTL("A wild {1} appeared!", name)
```

When English copy changes, translations keyed on that sentence break.

## Bridge with `source_text`

During migration, map legacy source strings to stable keys:

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

The adapter resolves the source string to a stable key, then evaluates the runtime message.

## Prefer stable keys in new code

New scripts should call keys directly:

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => name})
```

Stable keys survive refactors and keep translator diffs small.

## Migration plan

1. Install the matching Essentials adapter from a [release integration ZIP](/essential/installation).
2. Add `Locales/en.json`.
3. Add only the strings you are actively translating.
4. Route `_INTL` through the adapter for the chosen project area.
5. Add `source_text` mappings for those strings.
6. Run validation.
7. Add translated locale files.
8. Convert new or frequently edited scripts to direct `Kotoba.t` calls.

Avoid migrating every string at once. Start with menus, battle text, or one plugin.

## Import helpers

If the game ships compiled translations in `Data/messages.dat`, inspect it first:

```sh
bin/ruby18 bin/kotoba messages-dat-extract Data/messages.dat build/messages.extract.json
```

Then migrate it to a runtime catalog:

```sh
bin/ruby18 bin/kotoba messages-dat-migrate Data/messages.dat legacy Locales/legacy.json
```

Essentials paired-line text can be converted into a source-text bridge catalog:

```sh
bin/ruby18 bin/kotoba essentials-pairs-import intl.txt essentials Locales/en.essentials.json
```

Common PBS-style CSV files can be extracted into `data.<namespace>.<id>` catalogs:

```sh
bin/ruby18 bin/kotoba pbs-extract moves PBS/moves.txt Locales/en.moves.json
bin/ruby18 bin/kotoba pbs-extract items PBS/items.txt Locales/en.items.json
bin/ruby18 bin/kotoba pbs-extract abilities PBS/abilities.txt Locales/en.abilities.json
bin/ruby18 bin/kotoba pbs-extract pokemon PBS/pokemon.txt Locales/en.pokemon.json
bin/ruby18 bin/kotoba pbs-extract types PBS/types.txt Locales/en.types.json
bin/ruby18 bin/kotoba pbs-extract trainers PBS/trainers.txt Locales/en.trainers.json
```

BES and v21-style projects may also ship `Text_english_core/` and `Text_english_game/` directories. Convert them with:

```sh
bin/ruby18 bin/kotoba text-english-import Text_english_core core Locales/en.core.json
bin/ruby18 bin/kotoba text-english-import Text_english_game game Locales/en.game.json
```

Map event dialogue can be imported from compiled `Data/Map*.rxdata` files:

```sh
bin/ruby18 bin/kotoba map-rxdata-import Data/Map001.rxdata maps Locales/en.maps.json
```

Copy external game files into a local `tmp/` or `build/` directory before running `bin/ruby18` through Docker.
