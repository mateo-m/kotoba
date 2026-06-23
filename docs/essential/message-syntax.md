# Message syntax

Reference: placeholders, select, plural, apostrophes, RPG Maker control codes.

Plain text with optional placeholders: slots the game fills at runtime (names, counts, etc.).

| You | Page |
| --- | --- |
| Volunteer (spreadsheet) | [Placeholders](/translators/placeholders) |
| Developer (JSON in `Locales/`) | [Developer reference](#developer-reference) below |

Authors edit message strings in `Locales/<locale>.json` beside `Game.exe` ([Installing in a game §5](/essential/installation#_5-your-own-translations)). Subset of ICU MessageFormat: variables, `select`, cardinal `plural`, apostrophes, RPG Maker color codes.

---

## Developer reference

### Static text

Catalog (`Locales/en.json`):

```json
{
  "menu": {
    "save": "Save"
  }
}
```

```ruby
Kotoba.t("menu.save")
# => "Save"
```

### Variables

Catalog:

```json
{
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  },
  "npc": {
    "greeting": "Hello, {name}!"
  }
}
```

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
# => "A wild Pikachu appeared!"

Kotoba.t("npc.greeting", {"name" => "Ari"})
# => "Hello, Ari!"
```

String and symbol keys both work. Missing variables follow `config.missing_variable_policy`:

| Policy | `Kotoba.t("npc.greeting", {})` returns |
| --- | --- |
| `"keep"` (default) | `Hello, {name}!` |
| `"empty"` | `Hello, !` |
| `"error"` | raises `Kotoba::MessageEvaluationError` |

Keep `{name}` in every locale. See [Placeholders](/translators/placeholders).

### Select

Catalog:

```json
{
  "battle": {
    "pronoun_line": "{gender, select, female {She} male {He} other {They}} used {move}."
  }
}
```

```ruby
Kotoba.t("battle.pronoun_line", {"gender" => "female", "move" => "Thunderbolt"})
# => "She used Thunderbolt."

Kotoba.t("battle.pronoun_line", {"gender" => "unknown", "move" => "Tackle"})
# => "They used Tackle."
```

`other` is required. Unknown selector values use `other`.

### Plural

Catalog:

```json
{
  "bag": {
    "item_count": "{count, plural, =0 {No items} one {# item} other {# items}}"
  }
}
```

```ruby
Kotoba.t("bag.item_count", {"count" => 0})
# => "No items"

Kotoba.t("bag.item_count", {"count" => 1})
# => "1 item"

Kotoba.t("bag.item_count", {"count" => 5})
# => "5 items"
```

Branch order: exact (`=0`) → locale category (`one`, `few`, `many`) → `other`. `#` is the count inside plural branches. Count must be integer-like or evaluation raises.

### Nesting

Select and plural branches can nest other syntax. `config.max_message_depth` caps depth.

### Apostrophes

| Pattern | Result |
| --- | --- |
| `Bob''s item` | `Bob's item` |
| `'{count}'` | `{count}` |
| `Bob's item` | `Bob's item` |

### RPG Maker control codes

Catalog:

```json
{
  "npc": {
    "line": "\\c[3]{name}\\c[0] joined the party."
  }
}
```

```ruby
Kotoba.t("npc.line", {"name" => "Ari"})
# => "\c[3]Ari\c[0] joined the party."
```

Validation can flag translations that drop control codes. See [Validation CLI](/tooling/validation-cli).

### Plural locales supported today

English one/other, French `0`/`1` as `one`, Japanese/Korean/Chinese as `other`, Russian, Polish, Portuguese, Arabic, Czech, Slovak, Slovenian, Lithuanian, Latvian. Not full CLDR.
