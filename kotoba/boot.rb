# Template boot script for repository checkouts (bare RGSS).
# Release ZIPs generate their own kotoba/boot.rb per adapter.
#
# HOW TO USE IN A REAL GAME:
# 1. Copy kotoba/ next to Game.exe (from a release ZIP).
# 2. Do NOT double-click this file or run it with ruby in a terminal.
# 3. RPG Maker XP: Tools -> Script Editor -> new section "Kotoba" -> add:
#      load "kotoba/boot.rb"
# 4. Click OK, playtest. No Ruby error = Kotoba loaded.
#
# catalog_paths maps locale codes to JSON translation files on disk.
# This template points at the sample file kotoba/samples/bare_rgss/en.json.
# For your game, use Locales/en.json and edit the paths below.

require File.join(".", "kotoba", "core")
require File.join(".", "kotoba", "adapters", "bare_rgss")

Kotoba.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en"]
  config.catalog_paths = {
    "en" => ["kotoba/samples/bare_rgss/en.json"]
  }
  config.show_missing_keys = true
end

Kotoba.use_adapter("bare_rgss", {"load" => true})
