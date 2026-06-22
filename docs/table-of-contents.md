# Table of Contents

Kotoba is a small Ruby 1.8 i18n runtime for RPG Maker XP and Pokemon Essentials. It loads JSON catalogs at runtime, resolves locale fallbacks, and evaluates game-style message syntax. Adapters and CLI tools sit on top for Essentials bridges, imports, and translator handoff.

The sidebar lists every page. Use this one as a map.

## Where to start

| If you want to… | Go to |
| --- | --- |
| Drop Kotoba into a shipped game | [Installing in a game](/essential/installation) |
| Try the runtime from a git clone | [Quick Start](/essential/quick-start) |
| Send strings to a volunteer translator | [Spreadsheet handoff](/translators/handoff) |
| Translate lines yourself (no JSON) | [For translators](/translators/) |
| Move an Essentials project off `_INTL` gradually | [Essentials migration](/integration/pokemon-essentials-migration) |
| Work on Kotoba itself | [CI and releases](/contributors/ci) |

## Essential

Read these before adapters or tooling:

- [Quick Start](/essential/quick-start) — catalog, boot, and `Kotoba.t`
- [Installing in a game](/essential/installation) — release ZIPs and boot scripts
- [Catalog format](/essential/catalog-format) — nested JSON and lookup keys
- [Message syntax](/essential/message-syntax) — variables, plural, and apostrophes
- [Runtime API](/essential/runtime-api) — configuration, loading, and errors

## Integration

Opt-in adapters for bare RGSS, Pokemon Essentials, and custom kits:

- [Overview](/integration/) — registry API and built-in targets
- [Bare RGSS](/integration/bare-rgss) — plain RPG Maker XP
- [Pokemon Essentials](/integration/pokemon-essentials) — v16–v21 and BES
- [Third-party adapters](/integration/third-party) — register your own hook
- [Essentials migration](/integration/pokemon-essentials-migration) — `source_text` bridges

## Tooling

Validate catalogs, import game data, and hand strings to a TMS or spreadsheet:

- [Overview](/tooling/) — workflow and format guides
- [Spreadsheet handoff](/translators/handoff) — CSV export/import for volunteers
- [For translators](/translators/) — rules to share with non-technical volunteers
- [Validation CLI](/tooling/validation-cli) — load tests, imports, and cross-locale checks
- [TMS workflows](/tooling/tms) — nested JSON as source of truth
- [Crowdin](/tooling/crowdin) · [SimpleLocalize](/tooling/simplelocalize) · [Tolgee](/tooling/tolgee) · [XLIFF and PO](/tooling/xliff-po)

## Translators

- [For translators](/translators/) — what to edit in the spreadsheet
- [Spreadsheet handoff](/translators/handoff) — developer workflow for Essentials and fan projects

## Reference

- [Map event codes](/reference/map-event-codes) — RXDATA commands for map import
- [Compatibility](/reference/compatibility) — Ruby 1.8 gate and Docker matrix

## Contributors

- [CI](/contributors/ci) — lint, docs deploy, and releases
- [Docker images](/contributors/docker-images) — legacy Ruby images for tests
- [Roadmap](/contributors/roadmap) — planned work
