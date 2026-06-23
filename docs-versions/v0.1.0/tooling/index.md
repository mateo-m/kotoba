# Tooling

Catalogs live in `Locales/<locale>.json`. `bin/kotoba` (via `bin/ruby18`) validates them, imports game data, and exports interchange formats for translation tools.

Commands run from a cloned repo on a PC, not inside RPG Maker.

## Typical workflow

1. Author or import strings into `Locales/<locale>.json`.
2. Run [load-test and validate](/tooling/validation-cli) before handoff.
3. Export the format your TMS expects ([TMS workflows](/tooling/tms)).
4. Import translations back to nested JSON.
5. Validate translated catalogs against the source locale.

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```
