require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

tool_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "tools"))
$LOAD_PATH.unshift(tool_path) unless $LOAD_PATH.include?(tool_path)
require "catalog_tools"

adapter_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "adapters"))
$LOAD_PATH.unshift(adapter_path) unless $LOAD_PATH.include?(adapter_path)
require "essentials_bes"

class RealworldFixtureTest < RGSSI18nTestCase
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "realworld", "essentials-bes-sample"))

  def expected(name)
    RGSSI18nTools::CatalogTools.load_json(File.join(ROOT, "expected", name))
  end

  def test_messages_dat_migrate_matches_golden
    actual = RGSSI18nTools::CatalogTools.migrate_messages_dat(File.join(ROOT, "messages.dat"), "sample")

    assert_equal(expected("messages.migrated.json"), actual)
  end

  def test_intl_pairs_import_matches_golden
    actual = RGSSI18nTools::CatalogTools.import_essentials_pairs(
      File.join(ROOT, "intl.excerpt.txt"),
      "sample"
    )

    assert_equal(expected("intl.imported.json"), actual)
  end

  def test_pbs_moves_extract_matches_golden
    actual = RGSSI18nTools::CatalogTools.extract_pbs(
      "moves",
      File.join(ROOT, "pbs", "moves.excerpt.txt")
    )

    assert_equal(expected("moves.extracted.json"), actual)
  end

  def test_pbs_items_extract_matches_golden
    actual = RGSSI18nTools::CatalogTools.extract_pbs(
      "items",
      File.join(ROOT, "pbs", "items.excerpt.txt")
    )

    assert_equal(expected("items.extracted.json"), actual)
  end

  def test_pbs_abilities_extract_matches_golden
    actual = RGSSI18nTools::CatalogTools.extract_pbs(
      "abilities",
      File.join(ROOT, "pbs", "abilities.excerpt.txt")
    )

    assert_equal(expected("abilities.extracted.json"), actual)
  end

  def test_text_english_import_matches_golden
    actual = RGSSI18nTools::CatalogTools.import_text_english(
      File.join(ROOT, "text_english", "dialogue.excerpt.txt"),
      "sample"
    )

    assert_equal(expected("text_english.imported.json"), actual)
  end

  def test_map_rxdata_extract_matches_golden
    actual = RGSSI18nTools::CatalogTools.extract_map_rxdata(
      File.join(ROOT, "maps", "Map9001.rxdata")
    )

    assert_equal(expected("map.extracted.json"), actual)
  end

  def test_map_rxdata_import_matches_golden
    actual = RGSSI18nTools::CatalogTools.import_map_rxdata(
      File.join(ROOT, "maps", "Map9001.rxdata"),
      "sample"
    )

    assert_equal(expected("map.imported.json"), actual)
  end

  def test_essentials_bes_loads_intl_fixture_catalog
    RGSSI18n.use_adapter("essentials_bes", {
      "catalog_paths" => {"en" => [File.join(ROOT, "expected", "intl.imported.json")]},
      "load" => true
    })

    assert_equal("Save the game", RGSSI18n.t("sample.line_0001"))
    assert_equal("sample.line_0003", RGSSI18n.source_text_key("No items here.", {"default" => ""}))
  end
end
