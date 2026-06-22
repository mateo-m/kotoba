---
layout: home

hero:
  name: Kotoba
  text: Internationalization for retro fan games
  tagline: JSON catalogs, locale fallbacks, and dialog syntax for Ruby 1.8 RPG Maker XP and Essentials projects
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started
    - theme: alt
      text: Roadmap
      link: /roadmap

features:
  - title: Ruby 1.8 first
    details: Runtime code targets RPG Maker XP and RGSS1 constraints instead of modern Ruby only.
  - title: JSON catalogs
    details: Load nested locale files at runtime with fallback chains such as fr-CA -> fr -> en.
  - title: Game text syntax
    details: Variables, select, plural branches, and apostrophe escaping for dialog-heavy projects.
  - title: Validation tooling
    details: CLI commands for load tests, cross-locale checks, Essentials imports, map extraction, and translator handoff.
  - title: Opt-in adapters
    details: Integrate bare RGSS, Pokemon Essentials, or custom starter kits without patching the core.
  - title: Legacy test matrix
    details: Ruby 1.8, 1.9, 3.0, and 3.1 coverage through local Ruby and Docker images.
---

## Documentation

Use the sidebar to browse guides, adapter integration notes, tooling workflows, and project planning.

- [Getting Started](/getting-started): create a catalog, load the runtime, and translate strings.
- [Installing in a game](/installation): release ZIPs, boot scripts, and adapter matrix.
- [Runtime API](/runtime-api): public `Kotoba` methods, config fields, and error types.
- [Validation CLI](/validation-cli): load tests, schema checks, and import/export commands.
- [Pokemon Essentials Adapter](/adapters/pokemon-essentials): integrate Essentials v16-v21 and BES projects.
