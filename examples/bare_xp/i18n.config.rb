require_relative "../../kotoba/core"
require_relative "../../adapters/bare_rgss"

Kotoba.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"]
  }
end

Kotoba.use_adapter("bare_rgss", {"load" => true})
