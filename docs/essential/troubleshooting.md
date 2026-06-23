# Troubleshooting

How-to: fix install, playtest, and catalog problems.

Install walkthrough: [Installing in a game](/essential/installation).

---

## Install and file layout

### `LoadError: No such file or directory - kotoba/boot.rb`

Kotoba is not next to `Game.exe`. Common cause: an extra folder from the ZIP.

```text
Wrong:
  MyGame/kotoba-essentials-v20/kotoba/boot.rb

Right:
  MyGame/kotoba/boot.rb
  MyGame/Game.exe
```

Move `kotoba/` and `INSTALL.md` beside `Game.exe`.

### Double-clicked `boot.rb` and nothing happened

RPG Maker only runs scripts from the Script Editor.

**Tools → Script Editor** → `Kotoba` section above `Main`:

```ruby
load "kotoba/boot.rb"
```

### Wrong smoke test for your ZIP

| ZIP | Load line |
| --- | --- |
| `kotoba-essentials-*.zip` | `load "kotoba/samples/script_editor/essentials_smoke_test.rb"` |
| `kotoba-bare-rgss.zip` | `load "kotoba/samples/script_editor/bare_rgss_smoke_test.rb"` |

---

## Playtest results

### Smoke test works but dialog is still English

Kotoba is loaded; the game still calls `_INTL` or hard-coded strings. The smoke test only checks the sample catalog.

Fix: [Pokemon Essentials](/integration/pokemon-essentials) or [Essentials migration](/integration/pokemon-essentials-migration).

### Playtest OK, no message box

You used `load_only.rb` or `load "kotoba/boot.rb"`. Boot only, no test popup.

Use a smoke test script, or add `pbMessage(Kotoba.t(...))`.

### `LoadError` or `NameError` on playtest

| Error hint | Likely cause | Fix |
| --- | --- | --- |
| `kotoba/core` | Missing or wrong `kotoba/` path | [Install layout](#loaderror-no-such-file-or-directory---kotobabootrb) |
| `essentials_v20` (adapter) | Wrong Essentials ZIP | Matching ZIP from [Releases](https://github.com/mateo-m/kotoba/releases) |
| `Kotoba` uninitialized | Boot did not run | `Kotoba` section above `Main` |

---

## Translations and catalogs

### On screen: `translation missing: menu.save`

Key missing from the loaded catalog for the active locale.

1. Open the JSON in `kotoba/boot.rb` → `catalog_paths`.
2. Confirm nested key exists (`"menu": { "save": "Save" }` for `menu.save`).
3. Restart playtest after changing `catalog_paths`.

### On screen: `Hello, {name}!`

Script did not pass `name`, or `missing_variable_policy` is `"keep"`.

```json
{ "npc": { "greeting": "Hello, {name}!" } }
```

Wrong: `Kotoba.t("npc.greeting")` → `Hello, {name}!`

Right: `Kotoba.t("npc.greeting", {"name" => "Ari"})` → `Hello, Ari!`

### French line shows English

Locale not switched, or `Locales/fr.json` not in `catalog_paths`.

Set `available_locales` and `catalog_paths`, then `Kotoba.locale = "fr"` before the line runs.

---

## Validation

On a machine with this repo:

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

[Validation CLI](/tooling/validation-cli). Returned spreadsheets may drop placeholders or `\c[n]` codes. Send translators [Placeholders](/translators/placeholders).
