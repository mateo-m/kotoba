# Installing in a game

Download a release ZIP, extract it beside `Game.exe`, paste one line in Script Editor, and playtest. You should see a test translation on screen in about 15 minutes.

Git clone instead of a ZIP? [Quick Start](/essential/quick-start). Translators: [For translators](/translators/).

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

A passing smoke test only proves Kotoba loaded and read the **sample** catalog. It does not translate existing game dialog. After it works, continue to [§5 Your own translations](#5-your-own-translations) and [Pokemon Essentials](/integration/pokemon-essentials) or [Essentials migration](/integration/pokemon-essentials-migration) to bridge `_INTL`.

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

`{pokemon}` is filled at runtime. Translators keep that placeholder in every locale. See [Placeholders](/translators/placeholders).

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

1. Create `Locales/en.json` (and `fr.json`, etc.) next to `Game.exe`.
2. Edit `kotoba/boot.rb` on disk: set `catalog_paths` and `available_locales`.
3. In Script Editor, replace the smoke-test line with `load "kotoba/boot.rb"`.

Inside `kotoba/boot.rb` (Essentials v20 ZIP, paths updated):

```ruby
Kotoba.configure do |config|
  config.catalog_paths = {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  }
  config.available_locales = ["en", "fr"]
end
```

Release ZIPs already call `Kotoba.use_adapter` at the end of `boot.rb`. After editing paths, save the file and playtest. Config fields: [Runtime API](/essential/runtime-api#configuration).

Next: [Catalog format](/essential/catalog-format), [Pokemon Essentials](/integration/pokemon-essentials) or [Essentials migration](/integration/pokemon-essentials-migration).
