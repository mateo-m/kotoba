require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper"))

adapter_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba", "adapters"))
$LOAD_PATH.unshift(adapter_path) unless $LOAD_PATH.include?(adapter_path)
require "bare_rgss"

class BareRGSSAdapterTest < KotobaTestCase
  FIXTURE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "fixtures", "catalogs"))

  def test_adapter_can_configure_and_load_catalog_paths
    Kotoba.use_adapter("bare_rgss", {
      "catalog_paths" => {
        "en" => [File.join(FIXTURE_ROOT, "en_ui.json")]
      },
      "load" => true
    })

    assert_equal("Save", Kotoba.t("menu.save"))
  end

  def test_translate_message_resolves_kotoba_marker
    Kotoba.load_hash("en", {"menu" => {"save" => "Save"}})

    assert_equal("Save", Kotoba::Adapters::BareRGSS.translate_message("kotoba:menu.save", nil))
    assert_equal("Plain text", Kotoba::Adapters::BareRGSS.translate_message("Plain text", nil))
  end

  def test_global_message_helper_is_opt_in
    Kotoba.use_adapter("bare_rgss", {
      "catalog_paths" => {
        "en" => [File.join(FIXTURE_ROOT, "en_ui.json")]
      },
      "load" => true,
      "install_global" => true
    })

    assert_equal("Save", _KOTOBA_MESSAGE("kotoba:menu.save", nil))
  end
end
