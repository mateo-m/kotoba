# Bare RGSS Game Integration

Use this path for a plain RPG Maker XP/RGSS project that is not using Pokemon Essentials.

## Project Layout

Copy the runtime and adapter into your game project:

```text
Game/
  Data/
  Graphics/
  Locales/
    en.json
    fr.json
  Scripts/
    rgss_i18n_config.rb
  runtime/
    rgss_i18n_config.rb
    rgss_i18n_core.rb
    rgss_i18n_json.rb
    rgss_i18n_message_eval.rb
    rgss_i18n_plural_rules.rb
  adapters/
    registry.rb
    bare_rgss.rb
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

require File.join(I18N_ROOT, "runtime", "rgss_i18n_core")
require File.join(I18N_ROOT, "adapters", "bare_rgss")

RGSSI18n.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en", "fr"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  }
  config.strict = false
  config.show_missing_keys = true
end

RGSSI18n.use_adapter("bare_rgss", {"load" => true})
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
message = RGSSI18n.t("npc.greeting", {"name" => "Ari"})
```

Or use the global helper:

```ruby
message = _T("npc.greeting", {"name" => "Ari"})
```

If you use adapter markers, the bare adapter translates strings prefixed with `i18n:`:

```ruby
RGSSI18n::Adapters::BareRGSS.translate_message("i18n:menu.save", nil)
# => "Save"
```

Plain strings pass through unchanged:

```ruby
RGSSI18n::Adapters::BareRGSS.translate_message("Save", nil)
# => "Save"
```

## Changing Locale

```ruby
RGSSI18n.locale = "fr"
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
RGSSI18n.configure do |config|
  config.show_missing_keys = $DEBUG ? true : false
end
```

## Validate Before Copying Into The Game

Run outside RPG Maker:

```sh
bin/ruby18 bin/rgss-i18n load-test Locales/en.json
bin/ruby18 bin/rgss-i18n validate Locales/en.json Locales/fr.json
```

Fix catalog errors before importing files into the RPG Maker project.
