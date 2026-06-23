# Message syntax

Kotoba messages are plain text with optional **placeholders** — slots the game fills at runtime (Pokemon names, counts, player names, etc.).

| Audience | Start here |
| --- | --- |
| **Volunteer translators** (spreadsheet) | [Placeholders and special text](/translators/placeholders) |
| **Fangame developers** (JSON catalogs) | [Developer reference](#developer-reference) below |

Kotoba supports a small game-friendly subset: variables, `select`, cardinal `plural`, apostrophes, and RPG Maker color codes. It is **not** full ICU MessageFormat.

---

## Developer reference

Every example shows **catalog → call → result**.

### Static text

**Catalog** (`Locales/en.json`):

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

**Catalog:**

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

Translators must preserve `{name}` in every locale — see [Placeholders](/translators/placeholders).

### Select

**Catalog:**

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

**Catalog:**

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

Branch order: exact (`=0`) → locale category (`one`, `few`, `many`) → `other`. `#` expands to the count inside plural branches. Count must be present and integer-like or evaluation raises.

### Nesting

Select and plural branches can contain other syntax. Keep nesting shallow — `config.max_message_depth` limits parsing depth.

### Apostrophes

| Pattern | Result |
| --- | --- |
| `Bob''s item` | `Bob's item` |
| `'{count}'` | `{count}` |
| `Bob's item` | `Bob's item` |

### RPG Maker control codes

**Catalog:**

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

Compact cardinal rules exist for English-style one/other, French `0`/`1` as `one`, Japanese/Korean/Chinese as `other`, Russian, Polish, Portuguese, Arabic, Czech, Slovak, Slovenian, Lithuanian, and Latvian. Not a full CLDR implementation.

---

## See also

- [Placeholders](/translators/placeholders) — volunteer-facing guide
- [Catalog format](/essential/catalog-format) — JSON structure
- [Troubleshooting](/essential/troubleshooting) — visible `{name}` and missing keys
