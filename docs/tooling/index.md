# Tooling

Kotoba treats **nested per-locale JSON** as the source of truth at runtime. The CLI — `bin/kotoba`, run through `bin/ruby18` — validates catalogs, imports game data into JSON, and exports interchange formats for translation tools.

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
| [Validation CLI](/tooling/validation-cli) | Load tests, schema checks, PBS imports, map extraction |
| [TMS workflows](/tooling/tms) | General interchange rules and round-trips |
| [Crowdin](/tooling/crowdin) | Crowdin JSON |
| [SimpleLocalize](/tooling/simplelocalize) | SimpleLocalize flat JSON |
| [Tolgee](/tooling/tolgee) | Tolgee structured JSON |
| [XLIFF and PO](/tooling/xliff-po) | gettext PO and XLIFF |

## See also

- [Catalog format](/essential/catalog-format) — runtime JSON shape
- [Map event codes](/reference/map-event-codes) — RXDATA codes the map importer reads
- [Essentials migration](/integration/pokemon-essentials-migration) — gradual `_INTL` adoption
