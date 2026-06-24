# Introduction

You are reading the **latest** Kotoba guide. For a released library version, pick it in the version switcher in the navbar.

## What is Kotoba?

Kotoba loads JSON translation catalogs from your game folder at runtime. Drop a release ZIP beside `Game.exe`, add one line in Script Editor, and look up strings with `Kotoba.t` from your scripts.

Catalog (`Locales/en.json`):

```json
{
  "menu": {
    "save": "Save",
    "load": "Load"
  }
}
```

Boot line in Script Editor:

```ruby
load "kotoba/boot.rb"
```

Lookup:

```ruby
Kotoba.t("menu.save")  # => "Save"
```

That is the whole loop: JSON on disk, one boot line, translated text at runtime. No compile step.

## Essentials and bare RGSS

Release ZIPs cover bare RPG Maker XP and Pokemon Essentials v16–v21 (plus BES). Adapters bridge existing `_INTL` calls while you move copy into catalogs. See [Integration](/integration/) to match your kit.

:::info Prerequisites

You need RPG Maker XP with Script Editor access. For Essentials, download the ZIP that matches your kit version (v16–v21 or BES).

:::

## Pick your path

Different jobs start in different places:

- **Game folder with `Game.exe`** — [Installing in a game](/essential/installation)
- **Git clone for tooling or tests** — [Quick Start](/essential/quick-start)
- **Translation work** — [For translators](/translators/)
- **Install worked but something looks wrong** — [Troubleshooting](/essential/troubleshooting)

The rest of the guide covers catalog format, message syntax, placeholders, and export to spreadsheets. If you already know you want Kotoba beside `Game.exe`, skip ahead to [Installation](/essential/installation).
