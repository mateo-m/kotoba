# Spreadsheet handoff

The game loads `Locales/<locale>.json`. Spreadsheets are for translator round-trips in Sheets or Excel.

Clone this repo on a PC to run export/import commands ([Tooling](/tooling/)). Copy finished `Locales/*.json` into the game folder beside `Game.exe`.

Send translators [For translators](/translators/) and [Placeholders](/translators/placeholders) with the CSV.

## Workflow

1. Build or import English (`Locales/en.json`).
2. Export a spreadsheet.
3. Send the CSV or a `handoff/` zip.
4. Import the returned CSV into `Locales/fr.json` (or another locale).
5. Validate before shipping.

```sh
bin/ruby18 bin/kotoba spreadsheet-export Locales/en.json build/translate.csv i18n.metadata.json
bin/ruby18 bin/kotoba spreadsheet-import Locales/en.json build/translate.csv Locales/fr.json
bin/ruby18 bin/kotoba validate --human Locales/en.json Locales/fr.json
```

## One-command handoff folder

```sh
bin/ruby18 bin/kotoba handoff build/handoff-fr fr Locales/en.json i18n.metadata.json
```

Output:

- `spreadsheet.en.csv`: for translators
- `source.en.json`: developer copy of the catalog
- `pseudo.en.json`: layout QA with stretched text
- `metadata.json`: optional context when provided

Zip `build/handoff-fr/` and share it.

## Spreadsheet columns

| Column | Filled by | Notes |
| --- | --- | --- |
| `key` | export | Dot path (`battle.wild_appeared`). Do not edit. |
| `english` | export | Source locale text. |
| `translation` | translator | Imported back into the locale catalog. |
| `context` | export | From metadata or auto-generated from the key path. |
| `notes` | export | Metadata `description`, `speaker`, `max_length`. |

### Metadata file (optional)

`i18n.metadata.json` adds context per key:

```json
{
  "battle.wild_appeared": {
    "context": "Wild battle intro",
    "description": "Shown at the start of a wild encounter.",
    "speaker": "Narrator"
  }
}
```

Validate before export:

```sh
bin/ruby18 bin/kotoba schema metadata i18n.metadata.json
```

## Pokemon Essentials

1. Import PBS, `Text_english_*`, or map dialogue into English JSON, then export. Translators see game context, not script IDs.
2. Export one namespace (`menu`, `maps.map_0001`, `data.moves`) per person when starting out.
3. Use `{1}` in English when migrating `_INTL` if your translators already know Essentials placeholders. `{pokemon}` works too; validation matches English.
4. Export omits internal `source_text` migration rows.

Example:

```sh
bin/ruby18 bin/kotoba text-english-import Text_english_core core Locales/en.core.json
bin/ruby18 bin/kotoba spreadsheet-export Locales/en.core.json build/core-translate.csv
```

## Re-export with partial translations

```sh
bin/ruby18 bin/kotoba spreadsheet-import Locales/en.json build/translate.csv Locales/fr.json
bin/ruby18 bin/kotoba spreadsheet-export Locales/en.json build/translate.csv i18n.metadata.json Locales/fr.json
```

## Validation for humans

Default `validate` output is for developers. `--human` for pasting back to translators:

```sh
bin/ruby18 bin/kotoba validate --human Locales/en.json Locales/fr.json
```

Example:

```text
In fr.json: keep the same {placeholders} as English for "A wild {pokemon} appeared!" (key: battle.wild_appeared). Missing: {pokemon}.
```

JSON reports:

```sh
bin/ruby18 bin/kotoba validate-report --human Locales/en.json Locales/fr.json build/report.json
```
