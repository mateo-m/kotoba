# TMS Workflows

The runtime format is nested per-locale JSON. Translation management systems may prefer flat JSON, multi-language JSON, XLIFF, or PO. The CLI converts between those interchange formats and runtime JSON.

## Source Of Truth

Keep runtime catalogs as source of truth:

```text
Locales/en.json
Locales/fr.json
Locales/pt-BR.json
```

Export interchange files only when sending work to translators.

## Recommended Workflow

1. Validate the source catalog.
2. Export the format your TMS expects.
3. Translate.
4. Import back to nested JSON.
5. Validate translated JSON against the source catalog.

```sh
bin/ruby18 bin/rgss-i18n load-test Locales/en.json
bin/ruby18 bin/rgss-i18n validate Locales/en.json Locales/fr.json
```

## Supported Interchange

- flat dot-key JSON
- SimpleLocalize multi-language JSON
- XLIFF
- PO

Crowdin and Tolgee can use flat dot-key JSON workflows.
