# Validation CLI

Run every command through Ruby 1.8:

```sh
bin/ruby18 bin/kotoba <command> ...
```

Clone this repo on a PC. Shipped games only need the runtime from a release ZIP.

### Working with game files

Import and extract commands read paths on your PC, not inside RPG Maker. Copy `PBS/`, `Data/`, `Text_english_*`, or `.rxdata` files from your game into the repo (for example `build/mygame/…`), then point commands at those paths. When using Docker via `bin/ruby18`, inputs must stay under the repository directory.

## Load test

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
```

Checks:

- strict JSON parsing
- catalog root type
- valid string leaves
- message syntax

## Cross-locale validation

```sh
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

Checks:

- keys missing from the translated catalog
- placeholder mismatches
- RPG Maker control-code mismatches

Use the source locale as the first argument.

`--human` for output aimed at translators:

```sh
bin/ruby18 bin/kotoba validate --human Locales/en.json Locales/fr.json
```

Write a JSON report:

```sh
bin/ruby18 bin/kotoba validate-report Locales/en.json Locales/fr.json build/validation-report.json
bin/ruby18 bin/kotoba validate-report --human Locales/en.json Locales/fr.json build/validation-report.json
```

The report includes `ok`, `error_count`, grouped error counts, and the raw errors.

## Spreadsheet export and import

Export CSV with `key`, `english`, `translation`, `context`, `notes`:

```sh
bin/ruby18 bin/kotoba spreadsheet-export Locales/en.json build/translate.csv i18n.metadata.json
```

Import a completed spreadsheet back to nested JSON:

```sh
bin/ruby18 bin/kotoba spreadsheet-import Locales/en.json build/translate.csv Locales/fr.json
```

See [Spreadsheet handoff](/translators/handoff).

## Schema validation

```sh
bin/ruby18 bin/kotoba schema catalog Locales/en.json
bin/ruby18 bin/kotoba schema metadata metadata.json
bin/ruby18 bin/kotoba schema validation validation.json
```

Schemas live under `schemas/`.

## Flat key export and import

Export nested JSON to dot keys:

```sh
bin/ruby18 bin/kotoba flat-export Locales/en.json build/en.flat.json
```

Import dot keys back to nested JSON:

```sh
bin/ruby18 bin/kotoba flat-import build/fr.flat.json Locales/fr.json
```

## Pseudolocalization

```sh
bin/ruby18 bin/kotoba pseudo Locales/en.json Locales/pseudo.json
```

Pseudolocalization preserves placeholders and RPG Maker control codes. Use it to find hard-coded strings and layout assumptions.

## PBS Extraction

Extract common text from PBS-style CSV files and sectioned PBS files. Supported namespaces: `moves`, `items`, `abilities`, `pokemon`, `types`, `trainers`, `trainer_types`, and `map_metadata`.

```sh
bin/ruby18 bin/kotoba pbs-extract moves PBS/moves.txt Locales/en.moves.json
bin/ruby18 bin/kotoba pbs-extract items PBS/items.txt Locales/en.items.json
bin/ruby18 bin/kotoba pbs-extract abilities PBS/abilities.txt Locales/en.abilities.json
bin/ruby18 bin/kotoba pbs-extract pokemon PBS/pokemon.txt Locales/en.pokemon.json
bin/ruby18 bin/kotoba pbs-extract types PBS/types.txt Locales/en.types.json
bin/ruby18 bin/kotoba pbs-extract trainers PBS/trainers.txt Locales/en.trainers.json
bin/ruby18 bin/kotoba pbs-extract trainer_types PBS/trainertypes.txt Locales/en.trainer_types.json
bin/ruby18 bin/kotoba pbs-extract map_metadata PBS/map_metadata.txt Locales/en.map_metadata.json
```

The output uses the `data.<namespace>.<id>` shape used by adapter helpers. Items include `name`, `name_plural`, and `description`. Abilities include `name` and `description`. Pokemon sections include `name`, `kind`, `pokedex`, and optional `form_name`. Types include `name`. Trainer sections include `lose_text`, optional `end_speech`, `end_battle`, and `reg_speech`, plus `trainer_type`, `trainer_name`, and optional `version` parsed from the section header. Trainer type sections include `name`. Map metadata sections include `name`.

## messages.dat Extraction

Some Essentials games ship compiled translations in `Data/messages.dat`. Extract a readable structured dump:

```sh
bin/ruby18 bin/kotoba messages-dat-extract Data/messages.dat build/messages.extract.json
```

The extract output preserves section IDs, array entries, and source/target pairs from `OrderedHash` sections.

Migrate directly to this runtime's catalog shape:

```sh
bin/ruby18 bin/kotoba messages-dat-migrate Data/messages.dat legacy Locales/legacy.json
```

The migration output creates stable generated keys under the namespace you provide, plus `source_text` mappings for source-text sections. Essentials placeholders such as `{1}` and `{1:d}` are converted to runtime placeholders such as `{arg1}`.

If `bin/ruby18` is using Docker, the input `.dat` file must be under the repository directory or another path mounted into the container. Copy external game files into a local `tmp/` or `build/` directory before running the command.

## Essentials paired-line import

Import Essentials paired original/translated text files:

```sh
bin/ruby18 bin/kotoba essentials-pairs-import intl.txt essentials Locales/en.essentials.json
```

The output contains a `source_text` map and generated stable keys under the namespace you provide.

## Text_english Import

Import Essentials `Text_english_*` sectioned pair files. Each `[section]` header starts a new key group; lines alternate source and target text:

```sh
bin/ruby18 bin/kotoba text-english-import Text_english_core/TYPE_NAMES.txt core Locales/en.core.json
```

Import every `.txt` file in a directory:

```sh
bin/ruby18 bin/kotoba text-english-import Text_english_core core Locales/en.core.json
```

Directory imports merge files under `<namespace>.<filename>.<section>.line_*` keys.

## Map event text from `.rxdata`

Extract show-text and comment commands from compiled RPG Maker XP maps:

```sh
bin/ruby18 bin/kotoba map-rxdata-extract Data/Map001.rxdata build/map001.extract.json
```

Import map dialogue into a runtime catalog with `source_text` mappings:

```sh
bin/ruby18 bin/kotoba map-rxdata-import Data/Map001.rxdata maps Locales/en.maps.json
```

The importer reads event command codes `101` (show text), `401` (continuation), `102` (choices), `402` (choice branch), `108` (comment), `408` (comment continuation), and `_INTL` / `_ISPRINTF` strings inside script commands `355`, `356`, `655`, and `657` (double- or single-quoted). See [Map event codes](/reference/map-event-codes) for the full checklist. Copy external `.rxdata` files into the repository before running `bin/ruby18` through Docker.

## Translator handoff package

Create a small folder for translators:

```sh
bin/ruby18 bin/kotoba handoff build/handoff-en en Locales/en.json
```

The folder contains source JSON, flat JSON, pseudolocalized JSON, and a README.

## TMS export and import

SimpleLocalize multi-language JSON:

```sh
bin/ruby18 bin/kotoba tms-export simplelocalize_multi_language_json en Locales/en.json build/simplelocalize.json
bin/ruby18 bin/kotoba tms-import simplelocalize_multi_language_json fr build/simplelocalize.fr.json Locales/fr.json
```

XLIFF:

```sh
bin/ruby18 bin/kotoba tms-export xliff fr Locales/en.json build/fr.xliff
bin/ruby18 bin/kotoba tms-import xliff fr build/fr.xliff Locales/fr.json
```

PO:

```sh
bin/ruby18 bin/kotoba tms-export po fr Locales/en.json build/fr.po
bin/ruby18 bin/kotoba tms-import po fr build/fr.po Locales/fr.json
```

## Failure behavior

The CLI exits non-zero when validation fails.
