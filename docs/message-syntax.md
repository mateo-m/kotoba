# Message Syntax

The runtime supports a small next-intl-style subset. It is not full ICU MessageFormat.

## Static Text

```json
{
  "menu": {
    "save": "Save"
  }
}
```

## Variables

```json
{
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  }
}
```

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
```

String and symbol variable keys are accepted.

Missing interpolation variables follow `config.missing_variable_policy`:

- `"keep"`: leave `{name}` visible.
- `"empty"`: replace with an empty string.
- `"error"`: raise `Kotoba::MessageEvaluationError`.

## Select

```json
{
  "battle": {
    "pronoun_line": "{gender, select, female {She} male {He} other {They}} used {move}."
  }
}
```

`other` is required. Unknown selector values use `other`.

## Plural

```json
{
  "bag": {
    "item_count": "{count, plural, =0 {No items} one {# item} other {# items}}"
  }
}
```

Plural branch order:

1. exact branch such as `=0`
2. locale category such as `one`, `few`, or `many`
3. `other`

`other` is required. `#` expands to the current count inside plural branches.

Plural variables must be present and integer-like. Missing or non-integer counts raise `Kotoba::MessageEvaluationError`; silently treating a missing count as zero would hide real bugs.

## Nesting

Select and plural branches can contain other message syntax:

```json
{
  "party": {
    "summary": "{gender, select, female {{count, plural, one {She has # Pokemon} other {She has # Pokemon}}} male {{count, plural, one {He has # Pokemon} other {He has # Pokemon}}} other {{count, plural, one {They have # Pokemon} other {They have # Pokemon}}}}"
  }
}
```

Keep nesting shallow. `config.max_message_depth` exists to prevent runaway parser behavior.

## Apostrophes

Two apostrophes become one literal apostrophe:

```text
Bob''s item
```

Use apostrophes to quote syntax characters:

```text
'{count}'
```

Common apostrophes in words are preserved:

```text
Bob's item
```

## RPG Maker Control Codes

Control codes stay in the message:

```json
{
  "npc": {
    "line": "\\c[3]{name}\\c[0] joined the party."
  }
}
```

Pass variables normally:

```ruby
Kotoba.t("npc.line", {"name" => "Ari"})
```

## Current Plural Locales

The runtime includes compact cardinal rules for:

- English-style one/other languages.
- French `0` and `1` as `one`.
- Japanese, Korean, and Chinese as `other`.
- Russian.
- Polish.
- Portuguese.
- Arabic.
- Czech and Slovak.
- Slovenian.
- Lithuanian.
- Latvian.

This is enough for the current runtime tests. It is not a complete CLDR implementation.
