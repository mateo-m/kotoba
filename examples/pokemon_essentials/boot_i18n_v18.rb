require File.join(".", "kotoba", "core")
require File.join(".", "adapters", "essentials_v18")

Kotoba.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en", "fr"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  }
end

Kotoba.use_adapter("essentials_v18", {"load" => true})

def _INTL(*args)
  Kotoba::Adapters::EssentialsV18._INTL(*args)
end

def _ISPRINTF(*args)
  Kotoba::Adapters::EssentialsV18._ISPRINTF(*args)
end
