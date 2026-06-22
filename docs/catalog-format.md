# Catalog Format

Catalogs are strict JSON objects. The runtime reads them directly; there is no Marshal, `.dat`, or RPG Maker compile step in the core runtime.

## Shape

Use nested objects and string leaves:

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

Lookups use dot-separated paths:

```ruby
RGSSI18n.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
```

Avoid dots inside key names. Dots are reserved for lookup segments.

## Valid Leaves

Only strings are valid message leaves. These are rejected:

```json
{
  "menu": {
    "enabled": true,
    "order": 1,
    "items": ["Potion"]
  }
}
```

Rejecting non-string leaves at load time is intentional. A bad catalog should not become a missing translation later.

## JSON Rules

The bundled parser accepts strict JSON:

- UTF-8 BOM is stripped.
- Objects, arrays, strings, numbers, booleans, and null parse normally.
- `\uXXXX` escapes and surrogate pairs are decoded.
- Comments are not allowed.
- Trailing commas are not allowed.
- Leading-zero numbers are not allowed.

The runtime requires the catalog root to be an object.

## File Layout

Small projects can use one file per locale:

```text
Locales/en.json
Locales/fr.json
Locales/pt-BR.json
```

Larger projects can split namespaces:

```text
Locales/en/ui.json
Locales/en/battle.json
Locales/en/items.json
Locales/fr/ui.json
Locales/fr/battle.json
Locales/fr/items.json
```

Then configure ordered paths:

```ruby
config.catalog_paths = {
  "en" => [
    "Locales/en/ui.json",
    "Locales/en/battle.json",
    "Locales/en/items.json"
  ]
}
```

Later files override earlier keys unless `duplicate_key_policy` is set to `"error"`.

## Key Naming

Use stable semantic keys:

```json
{
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  }
}
```

Avoid keys based on the English sentence:

```json
{
  "A wild {1} appeared!": "A wild {pokemon} appeared!"
}
```

Source-text mappings are useful for migration, but new code should use stable keys.

## RPG Maker Control Codes

RPG Maker control codes are normal string content:

```json
{
  "npc": {
    "warning": "\\c[2]Careful!\\c[0]"
  }
}
```

Validation can detect when a translation drops or changes control codes.
