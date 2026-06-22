require File.join(".", "runtime", "rgss_i18n_core")
require File.join(".", "adapters", "bare_rgss")

RGSSI18n.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en", "fr"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  }
  config.show_missing_keys = true
end

RGSSI18n.use_adapter("bare_rgss", {"load" => true})
