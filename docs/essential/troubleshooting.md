# Troubleshooting

Fix common problems when installing Kotoba or running a playtest. Each item says what you see, why it happens, and what to do.

**Still installing?** Start with [Installing in a game](/essential/installation).

---

## Install and file layout

### `LoadError: No such file or directory - kotoba/boot.rb`

**Cause:** Kotoba files are not next to `Game.exe`. Common mistake: the ZIP created an extra folder.

**Fix:**

```text
Wrong:
  MyGame/kotoba-essentials-v20/kotoba/boot.rb

Right:
  MyGame/kotoba/boot.rb
  MyGame/Game.exe
```

Move `kotoba/` and `INSTALL.md` up so they sit beside `Game.exe`.

### Double-clicked `boot.rb` and nothing happened

**Cause:** RPG Maker does not run loose `.rb` files from the file explorer.

**Fix:** Open **Tools → Script Editor**, add a `Kotoba` section above `Main`, and use:

```ruby
load "kotoba/boot.rb"
```

### Wrong smoke test for your ZIP

| ZIP | Use this load line |
| --- | --- |
| `kotoba-essentials-*.zip` | `load "kotoba/samples/script_editor/essentials_smoke_test.rb"` |
| `kotoba-bare-rgss.zip` | `load "kotoba/samples/script_editor/bare_rgss_smoke_test.rb"` |

---

## Playtest results

### Smoke test works but all game dialog is still English / unchanged

**Cause:** Kotoba is loaded, but your game still calls legacy Essentials `_INTL` (or hard-coded strings). The smoke test only proves the **sample** catalog works.

**Fix:** [Pokemon Essentials integration](/integration/pokemon-essentials) or [Essentials migration](/integration/pokemon-essentials-migration).

### Playtest OK, no message box

**Cause:** You used `load "kotoba/samples/script_editor/load_only.rb"` or `load "kotoba/boot.rb"` — boot only, no test popup.

**Fix:** Use a smoke test script, or add your own `pbMessage(Kotoba.t(...))` line.

### `LoadError` or `NameError` on playtest

| Error hint | Likely cause | Fix |
| --- | --- | --- |
| `kotoba/core` | `kotoba/` folder missing or wrong path | [Install layout](#loaderror-no-such-file-or-directory---kotobabootrb) |
| `essentials_v20` (adapter) | Wrong Essentials ZIP for your kit | Download the matching ZIP from [Releases](https://github.com/mateo-m/kotoba/releases) |
| `Kotoba` uninitialized | Boot script did not run | Check Script Editor order — `Kotoba` section should be above `Main` |

---

## Translations and catalogs

### On screen: `translation missing: menu.save`

**Cause:** The key is not in the loaded catalog for the active locale.

**Fix:**

1. Open the JSON file listed in `kotoba/boot.rb` → `catalog_paths`.
2. Confirm the nested key exists (e.g. `"menu": { "save": "Save" }` for `menu.save`).
3. Run `Kotoba.load!` after changing `catalog_paths` (restart playtest).

### On screen: `Hello, {name}!` (placeholder visible)

**Cause:** The script did not pass `name`, or `missing_variable_policy` is `"keep"`.

**Catalog:**

```json
{ "npc": { "greeting": "Hello, {name}!" } }
```

**Wrong:**

```ruby
Kotoba.t("npc.greeting")
# => "Hello, {name}!"
```

**Right:**

```ruby
Kotoba.t("npc.greeting", {"name" => "Ari"})
# => "Hello, Ari!"
```

### French line shows English

**Cause:** Locale not switched, or `Locales/fr.json` not in `catalog_paths`.

**Fix:** Set `config.available_locales` and `catalog_paths`, then `Kotoba.locale = "fr"` before the line is shown.

---

## Validation (before shipping)

Run on a PC with the Kotoba repo:

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

See [Validation CLI](/tooling/validation-cli). Volunteer translations often fail validation when placeholders or `\c[n]` codes were edited — share [Placeholders](/translators/placeholders) with translators.

---

## See also

| Topic | Page |
| --- | --- |
| Install walkthrough | [Installing in a game](/essential/installation) |
| JSON shape | [Catalog format](/essential/catalog-format) |
| Placeholders | [Placeholders](/translators/placeholders) · [Message syntax](/essential/message-syntax) |
| Essentials bridge | [Pokemon Essentials](/integration/pokemon-essentials) |
