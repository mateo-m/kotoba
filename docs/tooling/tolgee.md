# Tolgee

Tolgee can use flat dot-key JSON as an interchange format.

Export:

```sh
bin/ruby18 bin/rgss-i18n flat-export Locales/en.json build/tolgee.en.json
```

Import:

```sh
bin/ruby18 bin/rgss-i18n flat-import build/tolgee.fr.json Locales/fr.json
```

Validate:

```sh
bin/ruby18 bin/rgss-i18n validate Locales/en.json Locales/fr.json
```

Keep placeholders and RPG Maker control codes unchanged unless you also update source validation rules.
