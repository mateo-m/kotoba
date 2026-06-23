# Installing in a game

This page is for **fangame developers** adding Kotoba to an existing RPG Maker XP or Pokemon Essentials project. You should already have a game folder with `Game.exe` in it.

| If you are… | Start here instead |
| --- | --- |
| Browsing the Kotoba git repo on your PC | [Quick Start](/essential/quick-start) |
| A volunteer translator (spreadsheet only) | [For translators](/translators/) |
| Working on Kotoba itself | [CI and releases](/contributors/ci) |

Release ZIPs include a short `INSTALL.md` that links here. The full guide lives on this website so docs can improve without a new library release.

---

## 1. Pick a release ZIP

Download **one** ZIP from [GitHub Releases](https://github.com/mateo-m/kotoba/releases):

| ZIP | Project type |
| --- | --- |
| `kotoba-bare-rgss.zip` | Plain RPG Maker XP |
| `kotoba-essentials-v20.zip` | Pokemon Essentials v20 |
| `kotoba-essentials-v16.zip` … `v21.zip` | Other Essentials versions |
| `kotoba-essentials-bes.zip` | BES Essentials fork |

Not sure which Essentials version? Check your kit name, credits, or download page (e.g. "Essentials v20.1").

---

## 2. Extract into your game folder

Your **game folder** is where `Game.exe` lives. Extract the ZIP **into** that folder — not into a subfolder.

### Correct layout

```text
MyFangame/
  Game.exe
  Locales/                       ← your translations later (game content)
    en.json
  kotoba/                        ← the library (one folder)
    boot.rb
    core.rb
    adapters/
    samples/
      script_editor/
      pokemon_essentials/en.json   ← Essentials ZIPs only
      bare_rgss/en.json            ← bare ZIP only
  INSTALL.md
```

### Wrong layout

```text
MyFangame/
  Game.exe
  kotoba-essentials-v20/    ← extra wrapper — move kotoba/ and INSTALL.md up
    kotoba/
```

---

## 3. Add Kotoba in Script Editor

RPG Maker does **not** run `.rb` files from double-click or a terminal. Add Kotoba through **Tools → Script Editor**.

1. Insert a section named **`Kotoba`** above **`Main`**.
2. Paste one of the lines below.
3. Click **OK**, then playtest (F12).

### Essentials (recommended first test)

```ruby
load "kotoba/samples/script_editor/essentials_smoke_test.rb"
```

### Bare RPG Maker XP

```ruby
load "kotoba/samples/script_editor/bare_rgss_smoke_test.rb"
```

### Boot only (no test popup)

```ruby
load "kotoba/boot.rb"
```

Other copy-paste scripts live in `kotoba/samples/script_editor/`.

---

## 4. What success looks like

### Essentials smoke test

The smoke test loads `kotoba/boot.rb`, reads the sample catalog, and shows a message box.

**Sample catalog** (`kotoba/samples/pokemon_essentials/en.json`):

```json
{
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  }
}
```

**Script** (inside `essentials_smoke_test.rb`):

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
```

**On screen:** `A wild Pikachu appeared!`

The `{pokemon}` part is filled in at runtime — translators keep that placeholder in every language. See [Placeholders](/translators/placeholders).

### Bare RGSS smoke test

**Sample catalog** (`kotoba/samples/bare_rgss/en.json`):

```json
{
  "menu": {
    "save": "Save"
  }
}
```

**Script:**

```ruby
Kotoba.t("menu.save")
```

**On screen:** `Kotoba says: Save`

### Playtest results

| Result | Meaning |
| --- | --- |
| Test message appears | Kotoba loaded and read the sample JSON |
| Game runs, no popup (`load_only`) | Kotoba loaded; no test line was added |
| `LoadError` / `No such file` | Files not next to `Game.exe` — see [Troubleshooting](/essential/troubleshooting) |
| Game runs, all text unchanged | Normal — existing `_INTL` still runs until you bridge it |

---

## 5. Point at your own translations

Copying files in does **not** auto-translate your game. After the smoke test works:

1. Create `Locales/en.json` (and `Locales/fr.json`, etc.) for real game text.
2. Edit `kotoba/boot.rb` so `catalog_paths` points at those files.
3. Replace the smoke-test load with `load "kotoba/boot.rb"`.

**`kotoba/boot.rb`** (Essentials v20 ZIP, paths updated):

```ruby
config.catalog_paths = {
  "en" => ["Locales/en.json"],
  "fr" => ["Locales/fr.json"]
}
config.available_locales = ["en", "fr"]
```

Read [Catalog format](/essential/catalog-format) for JSON shape, then [Pokemon Essentials](/integration/pokemon-essentials) or [Essentials migration](/integration/pokemon-essentials-migration) for bridging existing text.

---

## Next steps

| Goal | Page |
| --- | --- |
| Something went wrong | [Troubleshooting](/essential/troubleshooting) |
| JSON catalog rules | [Catalog format](/essential/catalog-format) |
| Placeholders for volunteers | [Placeholders](/translators/placeholders) |
| Developer message syntax | [Message syntax](/essential/message-syntax) |
| Bridge Pokemon Essentials | [Pokemon Essentials](/integration/pokemon-essentials) |
| Send strings to volunteers | [Spreadsheet handoff](/translators/handoff) |
| Validate catalogs before release | [Validation CLI](/tooling/validation-cli) |
