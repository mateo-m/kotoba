# Catalog format

Reference: JSON catalog shape, keys, and file layout.

Catalogs are strict JSON objects. Kotoba reads them at runtime. No Marshal, `.dat`, or RPG Maker compile step in the core.

In a fangame, create `Locales/<locale>.json` beside `Game.exe` ([Installing in a game §5](/essential/installation#_5-your-own-translations)). In a git clone, the same paths are relative to the repo root ([Quick Start](/essential/quick-start)).

## Shape

Nested objects, string leaves, dot-separated lookup keys.

`Locales/en.json`:

```json
{
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!",
    "item_count": "{count, plural, =0 {No items} one {# item} other {# items}}"
  },
  "menu": {
    "save": "Save"
  }
}
```

Lookups:

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
# => "A wild Pikachu appeared!"

Kotoba.t("battle.item_count", {"count" => 2})
# => "2 items"

Kotoba.t("menu.save")
# => "Save"
```

Avoid dots inside key names. Dots separate lookup segments only (`battle` + `wild_appeared` → `"battle.wild_appeared"`).

## Valid leaves

Only strings are valid message leaves. Numbers, booleans, arrays, or nested objects at a leaf path are rejected at load time.

## JSON rules

The bundled parser accepts strict JSON:

- UTF-8 BOM is stripped.
- Objects, arrays, strings, numbers, booleans, and null parse normally.
- `\uXXXX` escapes and surrogate pairs are decoded.
- Comments and trailing commas are not allowed.
- The catalog root must be an object.

## File layout

One file per locale (typical):

```text
Locales/en.json
Locales/fr.json
Locales/pt-BR.json
```

Split by namespace (larger projects):

```text
Locales/en/ui.json
Locales/en/battle.json
Locales/fr/ui.json
Locales/fr/battle.json
```

Config (later files override earlier keys):

```ruby
config.catalog_paths = {
  "en" => [
    "Locales/en/ui.json",
    "Locales/en/battle.json"
  ]
}
```

Unless `duplicate_key_policy` is `"error"`, later paths win on conflict.

## Key naming

Prefer stable semantic keys the game owns, not the English sentence:

Good:

```json
{
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  }
}
```

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
# => "A wild Pikachu appeared!"
```

Avoid for new code:

```json
{
  "A wild {1} appeared!": "A wild {pokemon} appeared!"
}
```

`source_text` mappings are for [Essentials migration](/integration/pokemon-essentials-migration), not greenfield keys.

## RPG Maker control codes

Color codes are normal string content:

Example:

```json
{
  "npc": {
    "warning": "\\c[2]Careful!\\c[0]"
  }
}
```

```ruby
Kotoba.t("npc.warning")
# => "\c[2]Careful!\c[0]"
```

Translators must preserve these. See [Placeholders](/translators/placeholders).

