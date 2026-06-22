require "test/unit"

kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"

class KotobaTestCase < Test::Unit::TestCase
  def default_test
    # Ruby 1.8 Test::Unit generates this for subclasses with no test_* methods.
  end

  def setup
    Kotoba.reset!
    Kotoba.configure do |config|
      config.default_locale = "en"
      config.available_locales = ["en", "fr", "fr-CA", "pt-BR", "ru", "pl"]
      config.fallbacks = {"default" => ["en"]}
      config.global_helper = true
      config.strict = false
      config.show_missing_keys = false
      config.diagnostics = false
    end
  end
end
