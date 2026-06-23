# SimpleLocalize

Single-language JSON can use the runtime catalog format directly.

For multi-language JSON, export a flattened all-language shape:

```sh
bin/ruby18 bin/kotoba tms-export simplelocalize_multi_language_json en Locales/en.json build/simplelocalize.json
```

Import translated multi-language JSON back into a runtime catalog:

```sh
bin/ruby18 bin/kotoba tms-import simplelocalize_multi_language_json fr build/simplelocalize.fr.json Locales/fr.json
```

The importer restores nested runtime JSON.
