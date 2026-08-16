---
title: Kotoba
description: i18n for RPG Maker XP and Pokemon Essentials.
sidebar:
  label: Home
  icon: house
  order: 1
---

Download a release ZIP, extract it beside `Game.exe`, paste one line in Script Editor, and playtest.

```ruby Script Editor
load "kotoba/boot.rb"
```

Kotoba reads JSON catalogs from the game folder at runtime. There is no compile step.

## Pick your path

<CardGroup cols={3}>
  <Card title="Introduction" href="/introduction" icon="book-open">
    What Kotoba is, a small catalog example, and which page to open next.
  </Card>
  <Card title="Installing in a game" href="/essential/installation" icon="download">
    Pick a release ZIP for your kit, extract it next to `Game.exe`, add the boot
    line, and run the smoke test.
  </Card>
  <Card title="For translators" href="/translators/" icon="languages">
    Edit JSON catalogs under `Locales/`, or export spreadsheets and import the
    finished files back into the game folder.
  </Card>
</CardGroup>
