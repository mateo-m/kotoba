# Installing in a game

This page is for **fangame developers** adding Kotoba to an existing RPG Maker XP or Pokemon Essentials project. You should already have a game folder with `Game.exe` in it.

If you are browsing the Kotoba git repository instead, use [Quick Start](/essential/quick-start) for a code-only walkthrough.

## About `INSTALL.md` in release ZIPs

Each integration ZIP includes a short `INSTALL.md` that links here. It only lists facts tied to that package (adapter name, sample paths, smoke-test file). **The full guide lives on this website** so documentation can improve without cutting a new library release. `MANIFEST.json` also includes a `docs_install_url` field with the same link.

## Example walkthrough (Essentials v20)

This is a concrete example. Match the names to your project.

**Project:** `Pokemon Titanium` (fan game, Essentials v20)
**ZIP:** `kotoba-essentials-v20.zip`
**Game folder:** `C:\Games\Pokemon Titanium\` (contains `Game.exe`)

### 1. Extract the ZIP

After extracting, `C:\Games\Pokemon Titanium\` contains:

```text
Pokemon Titanium/
  Game.exe
  Data/
  kotoba/
    boot.rb
    core.rb
    adapters/
      essentials_v20.rb
      ...
    samples/
      pokemon_essentials/
        en.json
      script_editor/
        essentials_smoke_test.rb
        load_only.rb
        README.md
  INSTALL.md                     ← links to online guide (not a full copy)
```

`INSTALL.md` in the ZIP is a short pointer to this page. Documentation updates ship with the website, not with every library release.

### 2. Add one line in Script Editor

Open **Tools → Script Editor**. Script list **before**:

```text
[Settings]
[Pokemon Essentials]
[... other plugins ...]
[Main]
```

Insert **`[Kotoba]`** between plugins and `Main`. Put this in it:

```ruby
load "kotoba/samples/script_editor/essentials_smoke_test.rb"
```

Script list **after**:

```text
[Settings]
[Pokemon Essentials]
[... other plugins ...]
[Kotoba]          ← new
[Main]
```

Click **OK**. Playtest (F12).

**Expected result:** a message box saying **"A wild Pikachu appeared!"**
That string comes from the sample JSON — not from your game's PBS files yet.

### 3. What just happened (same example)

| Step | What ran | Example value |
| --- | --- | --- |
| Script Editor | `load "kotoba/samples/script_editor/essentials_smoke_test.rb"` | Loads the example script from disk |
| Example script | `load "kotoba/boot.rb"` | Boots Kotoba + `essentials_v20` adapter |
| Boot script | `catalog_paths` → `kotoba/samples/pokemon_essentials/en.json` | Reads sample catalog |
| Sample JSON | key `battle.wild_appeared` | `"A wild {pokemon} appeared!"` |
| Example script | `Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})` | **"A wild Pikachu appeared!"** |

After this works, replace the smoke test with `load "kotoba/samples/script_editor/load_only.rb"` (boot only, no popup).

---

## Example walkthrough (plain RPG Maker XP)

**Project:** `My RPG` (no Essentials)
**ZIP:** `kotoba-bare-rgss.zip`

Script Editor section `Kotoba`:

```ruby
load "kotoba/samples/script_editor/bare_rgss_smoke_test.rb"
```

**Expected result:** **"Kotoba says: Save"**

Sample JSON path: `kotoba/samples/bare_rgss/en.json`

---

## Copy-paste examples (in every release ZIP)

Open `kotoba/samples/script_editor/` in your game folder.

| File | Paste or `load` when… |
| --- | --- |
| `essentials_smoke_test.rb` | Essentials — boot + test message (recommended first test) |
| `bare_rgss_smoke_test.rb` | Bare RGSS — boot + test message |
| `load_only.rb` | Boot only, no test popup |
| `README.md` | Short index of the above |

**One-line style** (paste into Script Editor):

```ruby
load "kotoba/samples/script_editor/essentials_smoke_test.rb"
```

**Copy-paste style:** open the `.rb` file in Notepad, select all, paste into the `Kotoba` script section.

Both do the same thing.

---

## What Kotoba does

Kotoba reads **locale JSON files** (translation catalogs) and returns strings from keys:

```ruby
Kotoba.t("menu.save")  # => "Save"  (if en.json has menu.save)
```

It does **not** auto-translate your whole game when you copy files in. Step one is booting the runtime. Step two is pointing your scripts and catalogs at real game text.

---

## Pick a release ZIP

Download **one** ZIP from [GitHub Releases](https://github.com/mateo-m/kotoba/releases):

| ZIP | Example project type |
| --- | --- |
| `kotoba-bare-rgss.zip` | Plain RPG Maker XP |
| `kotoba-essentials-v20.zip` | Pokemon Essentials v20 (like the walkthrough above) |
| `kotoba-essentials-v16.zip` … `v21.zip` | Other Essentials versions |
| `kotoba-essentials-bes.zip` | BES Essentials fork |

Not sure which Essentials version? Check your kit name, credits, or download page (e.g. "Essentials v20.1").

---

## Step 1 — Copy files into the game folder

Your **game folder** contains `Game.exe`. Extract the ZIP **into** that folder.

### Correct layout

```text
MyFangame/
  Game.exe
  kotoba/
    boot.rb
    core.rb
    adapters/
    samples/
      script_editor/
      pokemon_essentials/en.json   ← Essentials ZIPs
      bare_rgss/en.json            ← bare ZIP only
  INSTALL.md                     ← links to online guide
```

Kotoba ships as **one folder**. Your real translation files live elsewhere (for example `Locales/en.json`).

### Wrong layout

```text
MyFangame/
  Game.exe
  kotoba-essentials-v20/    ← extra folder — move contents up
    kotoba/
    INSTALL.md
```

---

## Step 2 — Confirm files on disk

| Path | Example (Essentials v20) |
| --- | --- |
| `kotoba/samples/script_editor/essentials_smoke_test.rb` | Your first-test script |
| `kotoba/samples/pokemon_essentials/en.json` | Sample catalog |
| `kotoba/adapters/essentials_v20.rb` | Adapter (name matches ZIP) |
| `kotoba/core.rb` | Runtime |
| `kotoba/boot.rb` | Boot script |

---

## Step 3 — Script Editor

RPG Maker does **not** run `.rb` files from double-click or terminal. Add Kotoba to `Data/Scripts.rxdata` via **Tools → Script Editor**.

1. Insert section **`Kotoba`** above **`Main`**.
2. Add one of the [example loads](#copy-paste-examples-in-every-release-zip), or `load "kotoba/boot.rb"` for boot only.
3. Click **OK**.

### Example: full `Kotoba` section (Essentials smoke test)

This is the full contents of `kotoba/samples/script_editor/essentials_smoke_test.rb`:

```ruby
load "kotoba/boot.rb"

if defined?(pbMessage) && defined?(Kotoba)
  pbMessage(Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"}))
end
```

### Example: full `Kotoba` section (boot only)

From `kotoba/samples/script_editor/load_only.rb`:

```ruby
load "kotoba/boot.rb"
```

---

## Step 4 — Playtest

| Result | Meaning |
| --- | --- |
| Test message appears | Kotoba loaded and read the sample JSON |
| Game runs, no popup (load_only) | Kotoba loaded; no test line was added |
| `LoadError` / `No such file` | Files not next to `Game.exe` — fix [Step 1](#step-1-copy-files-into-the-game-folder) |
| Game runs, all text unchanged | Normal — existing `_INTL` still runs until you bridge it |

---

## Example: what is in the sample JSON?

**Essentials** (`kotoba/samples/pokemon_essentials/en.json`):

```json
{
  "source_text": {
    "A wild {1} appeared!": "battle.wild_appeared",
    "You have {1:d} coins.": "ui.coins"
  },
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  },
  "ui": {
    "coins": "You have {count} coins."
  }
}
```

| JSON key | Example lookup | Returns |
| --- | --- | --- |
| `battle.wild_appeared` | `Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"})` | `A wild Pikachu appeared!` |
| `menu.save` | *(not in Essentials sample)* | — |

**Bare RGSS** (`kotoba/samples/bare_rgss/en.json`):

```json
{
  "menu": {
    "save": "Save",
    "load": "Load"
  },
  "npc": {
    "greeting": "Hello, {name}!"
  }
}
```

| JSON key | Example lookup | Returns |
| --- | --- | --- |
| `menu.save` | `Kotoba.t("menu.save")` | `Save` |
| `npc.greeting` | `Kotoba.t("npc.greeting", {"name" => "Ash"})` | `Hello, Ash!` |

Nested JSON keys become dot paths: `menu` → `save` → `"menu.save"`.

---

## Example: `catalog_paths` connects locale → JSON file

From `kotoba/boot.rb` (Essentials v20 ZIP):

```ruby
config.catalog_paths = {
  "en" => ["kotoba/samples/pokemon_essentials/en.json"]
}
```

Read as: *for locale `en`, load `kotoba/samples/pokemon_essentials/en.json` from the game folder.*

### Example: your own `Locales/` later

```text
MyFangame/
  Locales/
    en.json
    fr.json
```

```ruby
config.catalog_paths = {
  "en" => ["Locales/en.json"],
  "fr" => ["Locales/fr.json"]
}
config.available_locales = ["en", "fr"]
```

**Example:** copy the sample file to start your real catalog:

1. Copy `kotoba/samples/pokemon_essentials/en.json` → `Locales/en.json`
2. Edit `kotoba/boot.rb` paths to `Locales/en.json`
3. Add strings as you translate each part of the game

See [Catalog format](/essential/catalog-format) and [Essentials migration](/integration/pokemon-essentials-migration).

---

## Example: full boot script (Essentials v20 ZIP)

```ruby
require File.join(".", "kotoba", "core")
require File.join(".", "kotoba", "adapters", "essentials_v20")

Kotoba.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en"]
  config.catalog_paths = {
    "en" => ["kotoba/samples/pokemon_essentials/en.json"]
  }
end

Kotoba.use_adapter("essentials_v20", {"load" => true})
```

---

## Troubleshooting examples

| What you see | Example fix |
| --- | --- |
| `LoadError (No such file or directory - kotoba/boot.rb)` | ZIP contents are inside `kotoba-essentials-v20/` subfolder — move them next to `Game.exe` |
| Double-clicked `boot.rb`, nothing happened | Use Script Editor + `load "kotoba/samples/script_editor/..."` |
| `load "kotoba/samples/script_editor/essentials_smoke_test.rb"` fails on bare RGSS ZIP | Use `bare_rgss_smoke_test.rb` instead |
| Playtest OK, no message box | You used `load_only.rb` — that is expected. Use smoke test or add your own `pbMessage` |
| Smoke test works, game dialogs unchanged | Expected. Next: [Pokemon Essentials](/integration/pokemon-essentials) `_INTL` bridge |

---

## Validate catalogs before release

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

Requires the [Kotoba git repo](https://github.com/mateo-m/kotoba) on a modern PC. See [Tooling](/tooling/).

## Developing Kotoba itself

See [CI](/contributors/ci).
