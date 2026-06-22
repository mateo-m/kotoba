require "test/unit"

runtime_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "runtime"))
$LOAD_PATH.unshift(runtime_path) unless $LOAD_PATH.include?(runtime_path)

require "rgss_i18n_core"

class RGSSI18nTestCase < Test::Unit::TestCase
  def default_test
    # Ruby 1.8 Test::Unit generates this for subclasses with no test_* methods.
  end

  def setup
    RGSSI18n.reset!
    RGSSI18n.configure do |config|
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
