require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

class CoreTest < RGSSI18nTestCase
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

  def test_plural_messages_work_through_core_lookup
    load_sample_catalogs

    assert_equal("2 items", RGSSI18n.t("battle.item_count", {"count" => 2}))
  end
end
