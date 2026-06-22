# Bare RGSS integration

For plain RPG Maker XP / RGSS projects — no Pokemon Essentials.

Install `kotoba-bare-rgss.zip` from [GitHub Releases](/essential/installation) into your game root, or copy only the `kotoba/` and `adapters/` trees from that archive. Load `examples/boot_kotoba.rb` after setting `config.catalog_paths`.

## Project layout

```text
Game/
  Data/
  Graphics/
  Locales/
    en.json
    fr.json
  Scripts/
    kotoba_boot.rb
  adapters/
    bare_rgss.rb
    registry.rb
  kotoba/
    config.rb
    core.rb
    json.rb
    message_eval.rb
    plural_rules.rb
```

The exact folder names can change, but keep paths simple. Old RGSS Ruby is not a good place for clever load logic.

## Catalog

`Locales/en.json`:

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

## Boot Script

Create a script section near the top of your RPG Maker scripts:

```ruby
I18N_ROOT = "."

require File.join(I18N_ROOT, "kotoba", "core")

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

## Translating Script Text

Use the runtime directly:

```ruby
message = Kotoba.t("npc.greeting", {"name" => "Ari"})
```

Or use the global helper installed by the runtime:

```ruby
message = _T("npc.greeting", {"name" => "Ari"})
```

## Changing Locale

```ruby
Kotoba.locale = "fr"
```

The runtime loads the new locale and its fallback chain on assignment.

## Suggested RPG Maker Usage

For script calls:

```ruby
pbMessage(_T("npc.greeting", {"name" => $game_player.name}))
```

For custom menus:

```ruby
commands = [
  _T("menu.save"),
  _T("menu.load")
]
```

For event script calls:

```ruby
$game_variables[12] = _T("menu.save")
```

For windows:

```ruby
class Window_Command
  def localized_command(key)
    _T("commands." + key.to_s)
  end
end
```

For a title screen command list:

```ruby
commands = [
  _T("title.new_game"),
  _T("title.continue"),
  _T("title.shutdown")
]
```

For debug-only missing-key visibility:

```ruby
Kotoba.configure do |config|
  config.show_missing_keys = $DEBUG ? true : false
end
```

## Optional: `i18n:` Prefix Adapter

If you want database or event text to carry translation keys inline (`"i18n:menu.save"`) instead of calling `_T` in script, copy the optional bare adapter too:

```text
  adapters/
    registry.rb
    bare_rgss.rb
```

Boot with:

```ruby
require File.join(I18N_ROOT, "kotoba", "core")
require File.join(I18N_ROOT, "adapters", "bare_rgss")

Kotoba.configure do |config|
  config.default_locale = "en"
  config.catalog_paths = {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  }
end

Kotoba.use_adapter("bare_rgss", {"load" => true})
```

Strings prefixed with `i18n:` translate through the adapter; plain strings pass through unchanged:

```ruby
Kotoba::Adapters::BareRGSS.translate_message("i18n:menu.save", nil)
# => "Save"

Kotoba::Adapters::BareRGSS.translate_message("Save", nil)
# => "Save"
```

Most bare RGSS projects do not need this. Prefer `_T("menu.save")` in script unless you already store `i18n:` markers in data.

## Validate Before Copying Into The Game

Run outside RPG Maker:

```sh
bin/ruby18 bin/kotoba load-test Locales/en.json
bin/ruby18 bin/kotoba validate Locales/en.json Locales/fr.json
```

Fix catalog errors before importing files into the RPG Maker project.
