require File.join(".", "runtime", "rgss_i18n_core")
require File.join(".", "adapters", "essentials_v18")

RGSSI18n.configure do |config|
  config.default_locale = "en"
  config.available_locales = ["en", "fr"]
  config.catalog_paths = {
    "en" => ["Locales/en.json"],
    "fr" => ["Locales/fr.json"]
  }
end

RGSSI18n.use_adapter("essentials_v18", {"load" => true})

def _INTL(*args)
  RGSSI18n::Adapters::EssentialsV18._INTL(*args)
end

def _ISPRINTF(*args)
  RGSSI18n::Adapters::EssentialsV18._ISPRINTF(*args)
end
