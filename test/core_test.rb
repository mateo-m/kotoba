require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))
require "fileutils"

class CoreTest < RGSSI18nTestCase
  FIXTURE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "catalogs"))

  def load_sample_catalogs
    RGSSI18n.load_hash("en", {
      "battle" => {
        "wild_appeared" => "A wild {pokemon} appeared!",
        "item_count" => "{count, plural, =0 {No items} one {# item} other {# items}}"
      },
      "menu" => {
        "save" => "Save",
        "quit" => "Quit"
      }
    })

    RGSSI18n.load_hash("fr", {
      "battle" => {
        "wild_appeared" => "Un {pokemon} sauvage apparait!"
      },
      "menu" => {
        "save" => "Sauvegarder"
      }
    })
  end

  def test_loads_hash_catalogs_and_translates_nested_keys
    load_sample_catalogs

    assert_equal("A wild Pikachu appeared!", RGSSI18n.t("battle.wild_appeared", {"pokemon" => "Pikachu"}))
  end

  def test_global_t_helper_uses_core_lookup
    load_sample_catalogs

    assert_equal("Save", _T("menu.save"))
  end

  def test_namespace_helper_prefixes_keys
    load_sample_catalogs
    battle = RGSSI18n.namespace("battle")

    assert_equal("A wild Eevee appeared!", battle.call("wild_appeared", {"pokemon" => "Eevee"}))
  end

  def test_resolves_automatic_language_and_default_fallbacks
    load_sample_catalogs

    assert_equal(["fr-CA", "fr", "en"], RGSSI18n.fallback_chain("fr_CA"))
    assert_equal("Sauvegarder", RGSSI18n.t("menu.save", nil, {"locale" => "fr-CA"}))
    assert_equal("Quit", RGSSI18n.t("menu.quit", nil, {"locale" => "fr-CA"}))
  end

  def test_uses_explicit_fallback_overrides
    load_sample_catalogs
    RGSSI18n.configure do |config|
      config.fallbacks = {"pt-BR" => ["en"], "default" => ["en"]}
    end

    assert_equal(["pt-BR", "en"], RGSSI18n.fallback_chain("pt_BR"))
  end

  def test_default_option_is_evaluated
    assert_equal("Hello, Oak!", RGSSI18n.t("missing.key", {"name" => "Oak"}, {"default" => "Hello, {name}!"}))
  end

  def test_source_text_lookup_accepts_sentences_with_dots
    RGSSI18n.load_hash("en", {
      "source_text" => {
        "Hello. {1}" => "legacy.line_0001"
      },
      "legacy" => {
        "line_0001" => "Hello, {arg1}."
      }
    })

    assert_equal("legacy.line_0001", RGSSI18n.source_text_key("Hello. {1}"))
  end

  def test_strict_missing_translation_raises
    RGSSI18n.configure do |config|
      config.strict = true
    end

    assert_raise(RGSSI18n::MissingTranslationError) do
      RGSSI18n.t("missing.key")
    end
  end

  def test_loads_json_catalogs_directly
    RGSSI18n.load_json("en", %({"menu":{"pokemon":"Pokemon"}}))

    assert_equal("Pokemon", RGSSI18n.t("menu.pokemon"))
  end

  def test_rejects_non_string_catalog_leaves
    assert_raise(RGSSI18n::CatalogError) do
      RGSSI18n.load_hash("en", {"menu" => {"pokemon" => 25}})
    end
  end

  def test_plural_messages_work_through_core_lookup
    load_sample_catalogs

    assert_equal("2 items", RGSSI18n.t("battle.item_count", {"count" => 2}))
  end

  def test_loads_configured_catalog_paths_and_merges_files
    RGSSI18n.configure do |config|
      config.catalog_paths = {
        "en" => [
          File.join(FIXTURE_ROOT, "en_ui.json"),
          File.join(FIXTURE_ROOT, "en_battle.json")
        ]
      }
    end

    RGSSI18n.load!

    assert_equal("Save", RGSSI18n.t("menu.save"))
    assert_equal("A wild Pikachu appeared!", RGSSI18n.t("battle.wild_appeared", {"pokemon" => "Pikachu"}))
  end

  def test_discovers_locale_catalog_files_from_configured_roots
    root = File.join(File.dirname(__FILE__), "tmp_catalog_discovery")
    FileUtils.rm_rf(root)
    FileUtils.mkdir_p(File.join(root, "en"))
    File.open(File.join(root, "en.json"), "wb") { |file| file.write("{\"menu\":{\"save\":\"Save\"}}") }
    File.open(File.join(root, "en", "battle.json"), "wb") { |file| file.write("{\"battle\":{\"start\":\"Fight\"}}") }

    RGSSI18n.configure do |config|
      config.catalog_discovery_paths = [root]
    end

    RGSSI18n.load!

    assert_equal("Save", RGSSI18n.t("menu.save"))
    assert_equal("Fight", RGSSI18n.t("battle.start"))
  ensure
    FileUtils.rm_rf(root) if root
  end

  def test_locale_change_handlers_fire_when_locale_changes
    events = []
    RGSSI18n.configure do |config|
      config.locale_change_handler = lambda { |old_locale, new_locale| events << ["config", old_locale, new_locale] }
    end
    RGSSI18n.on_locale_change(lambda { |old_locale, new_locale| events << ["registered", old_locale, new_locale] })

    RGSSI18n.locale = "fr_CA"
    RGSSI18n.locale = "fr-CA"

    assert_equal([
      ["config", "en", "fr-CA"],
      ["registered", "en", "fr-CA"]
    ], events)
  end

  def test_file_loader_can_supply_catalog_contents
    files = {
      "virtual/en.json" => "{\"menu\":{\"save\":\"Save\"}}"
    }
    RGSSI18n.configure do |config|
      config.catalog_paths = {"en" => ["virtual/en.json"]}
      config.file_loader = lambda { |path| files[path] }
    end

    RGSSI18n.load!

    assert_equal("Save", RGSSI18n.t("menu.save"))
  end

  def test_diagnostics_logs_missing_translations
    path = File.join(File.dirname(__FILE__), "tmp_missing.log")
    File.delete(path) if File.exist?(path)
    RGSSI18n.configure do |config|
      config.diagnostics = true
      config.diagnostics_file = path
      config.show_missing_keys = true
    end

    assert_equal("translation missing: missing.key", RGSSI18n.t("missing.key"))
    assert_equal("en missing.key\n", File.open(path, "rb") { |file| file.read })
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_duplicate_key_policy_can_raise_on_merge
    RGSSI18n.configure do |config|
      config.duplicate_key_policy = "error"
    end
    RGSSI18n.load_hash("en", {"menu" => {"save" => "Save"}})

    assert_raise(RGSSI18n::CatalogError) do
      RGSSI18n.load_hash("en", {"menu" => {"save" => "Store"}})
    end
  end

  def test_duplicate_key_policy_warns_when_overriding
    warnings = []
    RGSSI18n.configure do |config|
      config.warning_handler = lambda { |message| warnings << message }
    end
    RGSSI18n.load_hash("en", {"menu" => {"save" => "Save"}})
    RGSSI18n.load_hash("en", {"menu" => {"save" => "Store"}})

    assert_equal("Store", RGSSI18n.t("menu.save"))
    assert_equal(["duplicate catalog key save"], warnings)
  end

  def test_warns_for_large_catalog_files
    warnings = []
    RGSSI18n.configure do |config|
      config.warn_catalog_bytes = 1
      config.catalog_paths = {"en" => [File.join(FIXTURE_ROOT, "en_ui.json")]}
      config.warning_handler = lambda { |message| warnings << message }
    end

    RGSSI18n.load!

    assert(warnings.detect { |message| message.index("catalog is large") })
  end
end
