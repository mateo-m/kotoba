require_relative "../../runtime/rgss_i18n_core"
require_relative "../../adapters/bare_rgss"

RGSSI18n.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"]
  }
end

RGSSI18n.use_adapter("bare_rgss", {"load" => true})
