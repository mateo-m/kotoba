require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper"))

adapter_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "adapters"))
$LOAD_PATH.unshift(adapter_path) unless $LOAD_PATH.include?(adapter_path)
require "bare_rgss"

class BareRGSSAdapterTest < RGSSI18nTestCase
  FIXTURE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "fixtures", "catalogs"))

  def test_adapter_can_configure_and_load_catalog_paths
    RGSSI18n.use_adapter("bare_rgss", {
      "catalog_paths" => {
        "en" => [File.join(FIXTURE_ROOT, "en_ui.json")]
      },
      "load" => true
    })

    assert_equal("Save", RGSSI18n.t("menu.save"))
  end

  def test_translate_message_resolves_i18n_marker
    RGSSI18n.load_hash("en", {"menu" => {"save" => "Save"}})

    assert_equal("Save", RGSSI18n::Adapters::BareRGSS.translate_message("i18n:menu.save", nil))
    assert_equal("Plain text", RGSSI18n::Adapters::BareRGSS.translate_message("Plain text", nil))
  end

  def test_global_message_helper_is_opt_in
    RGSSI18n.use_adapter("bare_rgss", {
      "catalog_paths" => {
        "en" => [File.join(FIXTURE_ROOT, "en_ui.json")]
      },
      "load" => true,
      "install_global" => true
    })

    assert_equal("Save", _RGSSI18N_MESSAGE("i18n:menu.save", nil))
  end
end
