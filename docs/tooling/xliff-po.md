# XLIFF And PO

XLIFF and PO are interchange formats. The runtime still loads nested JSON.

Export:

```sh
bin/ruby18 bin/kotoba tms-export xliff fr Locales/en.json build/fr.xliff
bin/ruby18 bin/kotoba tms-export po fr Locales/en.json build/fr.po
```

Import:

```sh
bin/ruby18 bin/kotoba tms-import xliff fr build/fr.xliff Locales/fr.json
bin/ruby18 bin/kotoba tms-import po fr build/fr.po Locales/fr.json
```

The converter stores the catalog key in the XLIFF unit ID or PO `msgctxt`. Translators should edit target text only.
