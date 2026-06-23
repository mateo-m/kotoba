# TMS workflows

Kotoba keeps nested per-locale JSON at runtime. Translation tools want flat JSON, multi-language JSON, XLIFF, or PO. The CLI converts between those formats and your catalogs.

Commands use `bin/ruby18 bin/kotoba` on a **developer PC** with this repo cloned. See per-tool pages ([Crowdin](/tooling/crowdin), [SimpleLocalize](/tooling/simplelocalize), [Tolgee](/tooling/tolgee), [XLIFF and PO](/tooling/xliff-po)).

## Source of truth

Keep runtime catalogs as source of truth:

```text
Locales/en.json
Locales/fr.json
Locales/pt-BR.json
```

Export interchange files only when sending work to translators.

## Recommended workflow

1. Validate the source catalog.
2. Export the format your TMS expects.
3. Translate.
4. Import back to nested JSON.
5. Validate translated JSON against the source catalog.

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

## Supported interchange

- flat dot-key JSON
- SimpleLocalize multi-language JSON
- XLIFF
- PO

Crowdin and Tolgee can use flat dot-key JSON workflows.
