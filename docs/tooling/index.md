# Tooling

Nested per-locale JSON is the runtime source of truth. `bin/kotoba` (via `bin/ruby18`) validates catalogs, imports game data, and exports interchange formats.

## Typical workflow

1. Author or import strings into `Locales/<locale>.json`.
2. Run [load-test and validate](/tooling/validation-cli) before handoff.
3. Export the format your TMS expects.
4. Import translations back to nested JSON.
5. Validate translated catalogs against the source locale.

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

## Guides

| Guide | Use when |
| --- | --- |
| [Spreadsheet handoff](/translators/handoff) | Sheets / Excel workflows |
| [Validation CLI](/tooling/validation-cli) | Load tests, schema, PBS, map extraction |
| [TMS workflows](/tooling/tms) | Interchange rules and round-trips |
| [Crowdin](/tooling/crowdin) | Crowdin JSON |
| [SimpleLocalize](/tooling/simplelocalize) | SimpleLocalize flat JSON |
| [Tolgee](/tooling/tolgee) | Tolgee structured JSON |
| [XLIFF and PO](/tooling/xliff-po) | gettext PO and XLIFF |
