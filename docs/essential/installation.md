# Installing in a game

Tutorial: add Kotoba to an RPG Maker XP or Pokemon Essentials project with `Game.exe`.

Browsing the git repo instead? [Quick Start](/essential/quick-start). Translators: [For translators](/translators/). Contributors: [CI](/contributors/ci).

Release ZIPs include `INSTALL.md` linking here. This site updates from `main`; you do not need a new library release for doc fixes.

---

## 1. Pick a release ZIP

Download one ZIP from [GitHub Releases](https://github.com/mateo-m/kotoba/releases):

| ZIP | Project type |
| --- | --- |
| `kotoba-bare-rgss.zip` | Plain RPG Maker XP |
| `kotoba-essentials-v20.zip` | Pokemon Essentials v20 |
| `kotoba-essentials-v16.zip` … `v21.zip` | Other Essentials versions |
| `kotoba-essentials-bes.zip` | BES Essentials fork |

Match your kit name, credits, or download page (e.g. "Essentials v20.1").

---

## 2. Extract into your game folder

`Game.exe` defines the game folder. Extract the ZIP into that folder, not into a subfolder.

### Correct layout

```text
MyFangame/
  Game.exe
  Locales/                       ← your translations later
    en.json
  kotoba/
    boot.rb
    core.rb
    adapters/
    samples/
      script_editor/
      pokemon_essentials/en.json   ← Essentials ZIPs
      bare_rgss/en.json            ← bare ZIP
  INSTALL.md
```

### Wrong layout

```text
MyFangame/
  Game.exe
  kotoba-essentials-v20/    ← extra wrapper; move kotoba/ and INSTALL.md up
    kotoba/
```

---

## 3. Add Kotoba in Script Editor

RPG Maker does not run `.rb` files from the file explorer. Use **Tools → Script Editor**.

1. Insert a section named `Kotoba` above `Main`.
2. Paste one line below.
3. OK, then playtest (F12).

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

More scripts: `kotoba/samples/script_editor/`.

---

## 4. Smoke tests

### Essentials

Loads `kotoba/boot.rb`, reads the sample catalog, shows a message box.

Catalog (`kotoba/samples/pokemon_essentials/en.json`):

```json
{
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  }
}
```

Script (`essentials_smoke_test.rb`):

```ruby
Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})
```

On screen: `A wild Pikachu appeared!`

`{pokemon}` is filled at runtime. Translators keep that placeholder in every language. See [Placeholders](/translators/placeholders).

### Bare RGSS

Catalog (`kotoba/samples/bare_rgss/en.json`):

```json
{
  "menu": {
    "save": "Save"
  }
}
```

```ruby
Kotoba.t("menu.save")
```

On screen: `Kotoba says: Save`

### Playtest results

| Result | Meaning |
| --- | --- |
| Test message appears | Kotoba loaded and read the sample JSON |
| Game runs, no popup (`load_only`) | Boot OK; no test line |
| `LoadError` / `No such file` | Files not next to `Game.exe`. See [Troubleshooting](/essential/troubleshooting) |
| Game runs, text unchanged | Expected until you bridge `_INTL` |

---

## 5. Your own translations

Extracting the ZIP does not translate the game. After the smoke test:

1. Create `Locales/en.json` (and `fr.json`, etc.).
2. Point `catalog_paths` in `kotoba/boot.rb` at those files.
3. Replace the smoke-test load with `load "kotoba/boot.rb"`.

`kotoba/boot.rb` (Essentials v20 ZIP, paths updated):

```ruby
config.catalog_paths = {
  "en" => ["Locales/en.json"],
  "fr" => ["Locales/fr.json"]
}
config.available_locales = ["en", "fr"]
```

Then [Catalog format](/essential/catalog-format), [Pokemon Essentials](/integration/pokemon-essentials) or [Essentials migration](/integration/pokemon-essentials-migration).
