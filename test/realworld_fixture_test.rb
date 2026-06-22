require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

tool_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "tools"))
$LOAD_PATH.unshift(tool_path) unless $LOAD_PATH.include?(tool_path)
require "catalog_tools"

adapter_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "adapters"))
$LOAD_PATH.unshift(adapter_path) unless $LOAD_PATH.include?(adapter_path)
require "essentials_bes"

class RealworldFixtureTest < KotobaTestCase
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "realworld", "essentials-bes-sample"))

  def expected(name)
    KotobaTools::CatalogTools.load_json(File.join(ROOT, "expected", name))
  end

  def test_messages_dat_migrate_matches_golden
    actual = KotobaTools::CatalogTools.migrate_messages_dat(File.join(ROOT, "messages.dat"), "sample")

    assert_equal(expected("messages.migrated.json"), actual)
  end

  def test_intl_pairs_import_matches_golden
    actual = KotobaTools::CatalogTools.import_essentials_pairs(
      File.join(ROOT, "intl.excerpt.txt"),
      "sample"
    )

    assert_equal(expected("intl.imported.json"), actual)
  end

  def test_pbs_moves_extract_matches_golden
    actual = KotobaTools::CatalogTools.extract_pbs(
      "moves",
      File.join(ROOT, "pbs", "moves.excerpt.txt")
    )

    assert_equal(expected("moves.extracted.json"), actual)
  end

  def test_pbs_items_extract_matches_golden
    actual = KotobaTools::CatalogTools.extract_pbs(
      "items",
      File.join(ROOT, "pbs", "items.excerpt.txt")
    )

    assert_equal(expected("items.extracted.json"), actual)
  end

  def test_pbs_abilities_extract_matches_golden
    actual = KotobaTools::CatalogTools.extract_pbs(
      "abilities",
      File.join(ROOT, "pbs", "abilities.excerpt.txt")
    )

    assert_equal(expected("abilities.extracted.json"), actual)
  end

  def test_pbs_pokemon_extract_matches_golden
    actual = KotobaTools::CatalogTools.extract_pbs(
      "pokemon",
      File.join(ROOT, "pbs", "pokemon.excerpt.txt")
    )

    assert_equal(expected("pokemon.extracted.json"), actual)
  end

  def test_pbs_types_extract_matches_golden
    actual = KotobaTools::CatalogTools.extract_pbs(
      "types",
      File.join(ROOT, "pbs", "types.excerpt.txt")
    )

    assert_equal(expected("types.extracted.json"), actual)
  end

  def test_pbs_trainers_extract_matches_golden
    actual = KotobaTools::CatalogTools.extract_pbs(
      "trainers",
      File.join(ROOT, "pbs", "trainers.excerpt.txt")
    )

    assert_equal(expected("trainers.extracted.json"), actual)
  end

  def test_pbs_trainer_types_extract_matches_golden
    actual = KotobaTools::CatalogTools.extract_pbs(
      "trainer_types",
      File.join(ROOT, "pbs", "trainer_types.excerpt.txt")
    )

    assert_equal(expected("trainer_types.extracted.json"), actual)
  end

  def test_pbs_map_metadata_extract_matches_golden
    actual = KotobaTools::CatalogTools.extract_pbs(
      "map_metadata",
      File.join(ROOT, "pbs", "map_metadata.excerpt.txt")
    )

    assert_equal(expected("map_metadata.extracted.json"), actual)
  end

  def test_text_english_import_matches_golden
    actual = KotobaTools::CatalogTools.import_text_english(
      File.join(ROOT, "text_english", "dialogue.excerpt.txt"),
      "sample"
    )

    assert_equal(expected("text_english.imported.json"), actual)
  end

  def test_map_rxdata_extract_matches_golden
    actual = KotobaTools::CatalogTools.extract_map_rxdata(
      File.join(ROOT, "maps", "Map9001.rxdata")
    )

    assert_equal(expected("map.extracted.json"), actual)
  end

  def test_map_rxdata_import_matches_golden
    actual = KotobaTools::CatalogTools.import_map_rxdata(
      File.join(ROOT, "maps", "Map9001.rxdata"),
      "sample"
    )

    assert_equal(expected("map.imported.json"), actual)
  end

  def test_essentials_bes_loads_intl_fixture_catalog
    Kotoba.use_adapter("essentials_bes", {
      "catalog_paths" => {"en" => [File.join(ROOT, "expected", "intl.imported.json")]},
      "load" => true
    })

    assert_equal("Save the game", Kotoba.t("sample.line_0001"))
    assert_equal("sample.line_0003", Kotoba.source_text_key("No items here.", {"default" => ""}))
  end
end
