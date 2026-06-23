# Bare RGSS integration

How-to: wire Kotoba into plain RPG Maker XP / RGSS.

Install: [Installing in a game](/essential/installation). Sample catalog: `kotoba/samples/bare_rgss/en.json`. Covers layout, boot, and `kotoba:` inline markers after Kotoba loads.

## Project layout

```text
Game/
  Data/
  Graphics/
  Locales/
    en.json
    fr.json
  kotoba/
    boot.rb
    config.rb
    core.rb
    json.rb
    message_eval.rb
    plural_rules.rb
    adapters/
      bare_rgss.rb
      registry.rb
```

The exact folder names can change, but keep paths simple. Old RGSS Ruby is not a good place for clever load logic.

## Catalog

**`Locales/en.json`:**

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

**Lookups and results:**

```ruby
Kotoba.t("menu.save")
# => "Save"

Kotoba.t("npc.greeting", {"name" => "Ari"})
# => "Hello, Ari!"
```

## Boot script

Create a script section near the top of your RPG Maker scripts:

```ruby
KOTOBA_ROOT = "."

require File.join(KOTOBA_ROOT, "kotoba", "core")

Kotoba.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en", "fr"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  }
  config.strict = false
  config.show_missing_keys = true
end

Kotoba.load!
```

If your game packages files in a custom archive, set `config.file_loader`:

```ruby
config.file_loader = lambda do |path|
  # Return the file contents as a string.
  File.open(path, "rb") { |file| file.read }
end
```

## Translating script text

**Catalog** (same `Locales/en.json` as above):

```ruby
message = Kotoba.t("npc.greeting", {"name" => "Ari"})
# => "Hello, Ari!"

message = _T("npc.greeting", {"name" => "Ari"})
# => "Hello, Ari!"
```

## Changing locale

```ruby
Kotoba.locale = "fr"
```

The runtime loads the new locale and its fallback chain on assignment.

## Suggested RPG Maker usage

**Catalog** (`Locales/en.json`):

```json
{
  "menu": { "save": "Save", "load": "Load" },
  "npc": { "greeting": "Hello, {name}!" }
}
```

**In events or scripts:**

```ruby
pbMessage(_T("npc.greeting", {"name" => $game_player.name}))
# => "Hello, <player name>!"

commands = [_T("menu.save"), _T("menu.load")]
# => ["Save", "Load"]
```

For debug-only missing-key visibility:

```ruby
Kotoba.configure do |config|
  config.show_missing_keys = $DEBUG ? true : false
end
```

## Optional: `kotoba:` prefix adapter

If you want database or event text to carry translation keys inline (`"kotoba:menu.save"`) instead of calling `_T` in script, copy the optional bare adapter too:

```text
  kotoba/
    adapters/
      registry.rb
      bare_rgss.rb
```

Boot with:

```ruby
KOTOBA_ROOT = "."

require File.join(KOTOBA_ROOT, "kotoba", "core")
require File.join(KOTOBA_ROOT, "kotoba", "adapters", "bare_rgss")

Kotoba.configure do |config|
  config.default_locale = "en"
  config.catalog_paths = {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  }
end

Kotoba.use_adapter("bare_rgss", {"load" => true})
```

Strings prefixed with `kotoba:` translate through the adapter; plain strings pass through.

**Catalog:**

```json
{
  "menu": {
    "save": "Save"
  }
}
```

```ruby
Kotoba::Adapters::BareRGSS.translate_message("kotoba:menu.save", nil)
# => "Save"

Kotoba::Adapters::BareRGSS.translate_message("Save", nil)
# => "Save"
```

Most bare RGSS projects do not need this. Prefer `_T("menu.save")` in script unless you already store `kotoba:` markers in data.

## Validate before copying into the game

Run outside RPG Maker:

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

Fix catalog errors before importing files into the RPG Maker project.
