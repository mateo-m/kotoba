# Roadmap

This repo currently has the runtime core, validator/tooling layer, and opt-in adapter layer.

## Done

- Core `RGSSI18n` namespace.
- Runtime configuration object.
- Strict JSON parser.
- Hash, JSON, and configured catalog loading.
- Nested key lookup.
- Locale fallback chains.
- Message evaluator for interpolation, select, and cardinal plural.
- Diagnostics, duplicate-key policy, message depth limits, and missing-variable controls.
- JSON Schemas for catalogs, metadata, and validation config.
- Validator CLI commands for `load-test`, `validate`, and `schema`.
- Flat-key import/export, pseudolocalization, and TMS interchange helpers.
- XLIFF and PO export/import.
- Bare RGSS adapter.
- Fixture-backed Essentials adapters for v16, v17, v18, v19/v20, v21, and BES.
- Version-specific PE v19 and v20 adapter names backed by the shared v19/v20 implementation.
- Optional global patch installers for built-in adapters.
- Wider practical cardinal plural-rule coverage.
- Locale-change hooks.
- Optional catalog discovery paths.
- Plain-string message fast path.
- PBS text extraction for common Essentials PBS files.
- Essentials paired-line import.
- Translator handoff package generation.
- Richer JSON validation reports.
- CI documentation and GitHub Actions workflow.
- Integration examples for bare RGSS, Pokemon Essentials, and third-party adapters.
- Ruby 1.8-compatible lint and test path.
- Generic Docker images for Ruby 1.8 and 1.9.
- Lefthook pre-commit setup through Bun.

## Complete

The roadmap items previously listed for the runtime, adapters, and tooling have been implemented and covered by tests or documentation.

## Future Ideas

Planning belongs here so README and task-specific guides can stay focused on current behavior.

Scores use a 1-5 scale. Higher complexity means more implementation risk or maintenance burden. Higher priority means the work is more likely to unblock real projects.

| Idea | Complexity | Complexity Reasoning | Priority | Priority Reasoning |
| --- | --- | --- | --- | --- |
| More real-world fixture coverage for individual games | 2 | Mostly fixture curation and test coverage, but provenance and licensing need care. | 5 | Better fixtures make every adapter claim more trustworthy and catch real compatibility gaps. |
| Automatic extraction from compiled RPG Maker map data | 4 | Requires parsing `.rxdata` event command structures across engine versions and game conventions. | 5 | Event text is usually the largest migration blocker for existing games. |
| Full PBS/database extraction beyond common text fields | 3 | The parsing model exists, but each PBS/database format needs field-specific rules and tests. | 4 | Data text is common in Essentials projects and complements the current partial PBS tooling. |
| Automatic rewriting of existing script calls to stable `RGSSI18n.t` calls | 5 | Needs Ruby source analysis, safe rewrites, placeholder mapping, and human-reviewable diffs. | 3 | Useful for large migrations, but source-text bridging already provides a safer gradual path. |
| Release packaging | 2 | Mostly repository hygiene, versioning, archives, and documented install artifacts. | 3 | Important once the API stabilizes, but less urgent than migration coverage. |
| RPG Maker editor integration | 5 | Requires tool UX outside the runtime and likely platform/editor-specific workflows. | 2 | Helpful long term, but not required for script-based adoption. |
| Locale-aware date, time, number, and list formatting | 4 | CLDR data and formatting behavior must stay small enough for Ruby 1.8/RGSS constraints. | 2 | Useful polish, but most current game text can use explicit catalog strings. |
| Full CLDR plural rules, including decimal operands | 3 | Needs broader rule data and decimal operand handling without bloating the runtime. | 2 | Current practical cardinal coverage handles the likely early locales. |
| Full ICU MessageFormat | 5 | Large grammar and semantics surface, with high risk of runtime size and compatibility creep. | 1 | The current ICU-like subset covers the intended game-dialog use cases. |

Runtime and tooling should remain separate. The runtime must stay small enough to run inside old RGSS Ruby.
