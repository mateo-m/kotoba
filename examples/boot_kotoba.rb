require File.join(".", "kotoba", "core")
require File.join(".", "adapters", "bare_rgss")

Kotoba.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en", "fr"]
  config.catalog_paths = {
    "en" => ["examples/bare_rgss/en.json"],
    "fr" => ["Locales/fr.json"]
  }
  config.show_missing_keys = true
end

Kotoba.use_adapter("bare_rgss", {"load" => true})
