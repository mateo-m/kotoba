# Spreadsheet handoff

Use spreadsheets when your translators are volunteers or hobbyists — not TMS professionals. Kotoba still keeps nested JSON as the runtime source of truth; the spreadsheet is the friendly handoff layer.

Share [For translators](/translators/) and [Placeholders and special text](/translators/placeholders) with volunteers so they know how to handle `{placeholders}` and color codes.

## Quick workflow

1. Build or import your English catalog (`Locales/en.json`).
2. Export a spreadsheet for translators.
3. Send the CSV (or a `handoff/` zip).
4. Import the returned CSV into `Locales/fr.json` (or another locale).
5. Validate with plain-language errors before shipping.

```sh
bin/ruby18 bin/kotoba spreadsheet-export Locales/en.json build/translate.csv i18n.metadata.json
bin/ruby18 bin/kotoba spreadsheet-import Locales/en.json build/translate.csv Locales/fr.json
bin/ruby18 bin/kotoba validate --human Locales/en.json Locales/fr.json
```

## One-command handoff folder

Creates a translator-ready folder with CSV, pseudolocale, and README:

```sh
bin/ruby18 bin/kotoba handoff build/handoff-fr fr Locales/en.json i18n.metadata.json
```

Output:

- `spreadsheet.en.csv` — send this to translators
- `source.en.json` — developer copy of the runtime catalog
- `pseudo.en.json` — layout QA with stretched text
- `metadata.json` — optional context copied through when provided

Zip `build/handoff-fr/` and share it on Discord, Google Drive, or email.

## Spreadsheet columns

| Column | Filled by | Notes |
| --- | --- | --- |
| `key` | export | Stable dot path (`battle.wild_appeared`). Translators should not edit. |
| `english` | export | Source locale text. |
| `translation` | translator | Imported back into the locale catalog. |
| `context` | export | From metadata, or auto-generated from the key path. |
| `notes` | export | Metadata `description`, `speaker`, and `max_length`. |

### Metadata file (optional)

`i18n.metadata.json` adds human context per key:

```json
{
  "battle.wild_appeared": {
    "context": "Wild battle intro",
    "description": "Shown at the start of a wild encounter.",
    "speaker": "Narrator"
  }
}
```

Validate metadata before export:

```sh
bin/ruby18 bin/kotoba schema metadata i18n.metadata.json
```

## Pokemon Essentials tips

1. **Import first, translate second** — pull PBS, `Text_english_*`, or map dialogue into English JSON, then export the spreadsheet. Translators see game context instead of script IDs.
2. **Start small** — export one namespace (`menu`, `maps.map_0001`, or `data.moves`) per volunteer.
3. **Use `{1}` in English when migrating `_INTL`** — hobby translators already know Essentials-style placeholders. Named placeholders like `{pokemon}` are fine too; validation enforces whichever English uses.
4. **Skip `source_text` rows** — export omits internal migration mappings under `source_text`.

Example Essentials import → spreadsheet path:

```sh
bin/ruby18 bin/kotoba text-english-import Text_english_core core Locales/en.core.json
bin/ruby18 bin/kotoba spreadsheet-export Locales/en.core.json build/core-translate.csv
```

## Re-export with partial translations

If a translator returns a half-finished sheet, import what you have, then re-export with the locale file filled in to show progress:

```sh
bin/ruby18 bin/kotoba spreadsheet-import Locales/en.json build/translate.csv Locales/fr.json
bin/ruby18 bin/kotoba spreadsheet-export Locales/en.json build/translate.csv i18n.metadata.json Locales/fr.json
```

## Validation for humans

Default `validate` output is developer-oriented. Use `--human` when pasting results back to translators:

```sh
bin/ruby18 bin/kotoba validate --human Locales/en.json Locales/fr.json
```

Example message:

```text
In fr.json: keep the same {placeholders} as English for "A wild {pokemon} appeared!" (key: battle.wild_appeared). Missing: {pokemon}.
```

JSON reports also accept the flag:

```sh
bin/ruby18 bin/kotoba validate-report --human Locales/en.json Locales/fr.json build/report.json
```

## See also

- [For translators](/translators/) — share this page with volunteers
- [Validation CLI](/tooling/validation-cli) — full command reference
- [Essentials migration](/integration/pokemon-essentials-migration) — importing source text before handoff
