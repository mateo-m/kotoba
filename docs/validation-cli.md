# Validation CLI

The CLI entrypoint is `bin/rgss-i18n`. Run it through Ruby 1.8:

```sh
bin/ruby18 bin/rgss-i18n <command> ...
```

## Load Test

```sh
bin/ruby18 bin/rgss-i18n load-test Locales/en.json
```

Checks:

- strict JSON parsing
- catalog root type
- valid string leaves
- message syntax

## Cross-Locale Validation

```sh
bin/ruby18 bin/rgss-i18n validate Locales/en.json Locales/fr.json
```

Checks:

- keys missing from the translated catalog
- placeholder mismatches
- RPG Maker control-code mismatches

Use the source locale as the first argument.

Write a JSON report:

```sh
bin/ruby18 bin/rgss-i18n validate-report Locales/en.json Locales/fr.json build/validation-report.json
```

The report includes `ok`, `error_count`, grouped error counts, and the raw errors.

## Schema Validation

```sh
bin/ruby18 bin/rgss-i18n schema catalog Locales/en.json
bin/ruby18 bin/rgss-i18n schema metadata i18n.metadata.json
bin/ruby18 bin/rgss-i18n schema validation i18n.validation.json
```

Schemas live under `schemas/`.

## Flat Key Export And Import

Export nested JSON to dot keys:

```sh
bin/ruby18 bin/rgss-i18n flat-export Locales/en.json build/en.flat.json
```

Import dot keys back to nested JSON:

```sh
bin/ruby18 bin/rgss-i18n flat-import build/fr.flat.json Locales/fr.json
```

## Pseudolocalization

```sh
bin/ruby18 bin/rgss-i18n pseudo Locales/en.json Locales/pseudo.json
```

Pseudolocalization preserves placeholders and RPG Maker control codes. Use it to find hard-coded strings and layout assumptions.

## PBS Extraction

Extract common text from PBS-style CSV files:

```sh
bin/ruby18 bin/rgss-i18n pbs-extract moves PBS/moves.txt Locales/en.moves.json
```

The output uses the `data.<namespace>.<id>` shape used by adapter helpers.

## messages.dat Extraction

Some Essentials games ship compiled translations in `Data/messages.dat`. Extract a readable structured dump:

```sh
bin/ruby18 bin/rgss-i18n messages-dat-extract Data/messages.dat build/messages.extract.json
```

The extract output preserves section IDs, array entries, and source/target pairs from `OrderedHash` sections.

Migrate directly to this runtime's catalog shape:

```sh
bin/ruby18 bin/rgss-i18n messages-dat-migrate Data/messages.dat legacy Locales/legacy.json
```

The migration output creates stable generated keys under the namespace you provide, plus `source_text` mappings for source-text sections. Essentials placeholders such as `{1}` and `{1:d}` are converted to runtime placeholders such as `{arg1}`.

If `bin/ruby18` is using Docker, the input `.dat` file must be under the repository directory or another path mounted into the container. Copy external game files into a local `tmp/` or `build/` directory before running the command.

## Essentials Paired-Line Import

Import Essentials paired original/translated text files:

```sh
bin/ruby18 bin/rgss-i18n essentials-pairs-import intl.txt essentials Locales/en.essentials.json
```

The output contains a `source_text` map and generated stable keys under the namespace you provide.

## Text_english Import

Import Essentials `Text_english_*` sectioned pair files. Each `[section]` header starts a new key group; lines alternate source and target text:

```sh
bin/ruby18 bin/rgss-i18n text-english-import Text_english_core/TYPE_NAMES.txt core Locales/en.core.json
```

Import every `.txt` file in a directory:

```sh
bin/ruby18 bin/rgss-i18n text-english-import Text_english_core core Locales/en.core.json
```

Directory imports merge files under `<namespace>.<filename>.<section>.line_*` keys.

## Map Event Text From `.rxdata`

Extract show-text and comment commands from compiled RPG Maker XP maps:

```sh
bin/ruby18 bin/rgss-i18n map-rxdata-extract Data/Map001.rxdata build/map001.extract.json
```

Import map dialogue into a runtime catalog with `source_text` mappings:

```sh
bin/ruby18 bin/rgss-i18n map-rxdata-import Data/Map001.rxdata maps Locales/en.maps.json
```

The importer reads event command codes `101` (show text), `401` (continuation), and `108` (comment). Copy external `.rxdata` files into the repository before running `bin/ruby18` through Docker.

## Translator Handoff Package

Create a small folder for translators:

```sh
bin/ruby18 bin/rgss-i18n handoff build/handoff-en en Locales/en.json
```

The folder contains source JSON, flat JSON, pseudolocalized JSON, and a README.

## TMS Export And Import

SimpleLocalize multi-language JSON:

```sh
bin/ruby18 bin/rgss-i18n tms-export simplelocalize_multi_language_json en Locales/en.json build/simplelocalize.json
bin/ruby18 bin/rgss-i18n tms-import simplelocalize_multi_language_json fr build/simplelocalize.fr.json Locales/fr.json
```

XLIFF:

```sh
bin/ruby18 bin/rgss-i18n tms-export xliff fr Locales/en.json build/fr.xliff
bin/ruby18 bin/rgss-i18n tms-import xliff fr build/fr.xliff Locales/fr.json
```

PO:

```sh
bin/ruby18 bin/rgss-i18n tms-export po fr Locales/en.json build/fr.po
bin/ruby18 bin/rgss-i18n tms-import po fr build/fr.po Locales/fr.json
```

The runtime still loads nested JSON. TMS files are interchange files only.

## Failure Behavior

The CLI exits non-zero when validation fails. Use it in pre-commit hooks and CI.
