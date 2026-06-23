# Crowdin

For Crowdin, use nested JSON directly or export flat dot keys.

Export:

```sh
bin/ruby18 bin/kotoba flat-export Locales/en.json build/crowdin.en.json
```

Import:

```sh
bin/ruby18 bin/kotoba flat-import build/crowdin.fr.json Locales/fr.json
```

Validate:

```sh
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

Tell translators not to edit placeholders such as `{pokemon}` or RPG Maker control codes such as `\\c[2]`.
