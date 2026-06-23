# Catalog format

Catalogs are strict JSON objects. Kotoba reads them at runtime — no Marshal, `.dat`, or RPG Maker compile step in the core.

## Shape

Nested objects, string leaves, dot-separated lookup keys:

**Catalog** (`Locales/en.json`):

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

**Lookups and results:**

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
# => "A wild Pikachu appeared!"

Kotoba.t("battle.item_count", {"count" => 2})
# => "2 items"

Kotoba.t("menu.save")
# => "Save"
```

Avoid dots inside key names — dots separate lookup segments only (`battle` + `wild_appeared` → `"battle.wild_appeared"`).

## Valid leaves

Only **strings** are valid message leaves. Numbers, booleans, arrays, or nested objects at a leaf path are rejected at load time.

## JSON rules

The bundled parser accepts strict JSON:

- UTF-8 BOM is stripped.
- Objects, arrays, strings, numbers, booleans, and null parse normally.
- `\uXXXX` escapes and surrogate pairs are decoded.
- Comments and trailing commas are **not** allowed.
- The catalog root must be an object.

## File layout

**One file per locale** (typical for fan games):

```text
Locales/en.json
Locales/fr.json
Locales/pt-BR.json
```

**Split by namespace** (larger projects):

```text
Locales/en/ui.json
Locales/en/battle.json
Locales/fr/ui.json
Locales/fr/battle.json
```

**Config** (later files override earlier keys):

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

Prefer **stable semantic keys** the game owns — not the English sentence:

**Good:**

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

**Avoid for new code:**

```json
{
  "A wild {1} appeared!": "A wild {pokemon} appeared!"
}
```

`source_text` mappings are for [Essentials migration](/integration/pokemon-essentials-migration), not greenfield keys.

## RPG Maker control codes

Color codes are normal string content:

**Catalog:**

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

Translators must preserve these — see [Placeholders](/translators/placeholders).

## See also

- [Placeholders](/translators/placeholders) — volunteer guide
- [Message syntax](/essential/message-syntax) — developer reference
- [Installing in a game](/essential/installation) — where `Locales/` lives in your project
- [Validation CLI](/tooling/validation-cli) — catch bad JSON before playtest
