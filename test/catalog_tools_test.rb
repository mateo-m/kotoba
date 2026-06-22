require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))
require "fileutils"

tool_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "tools"))
$LOAD_PATH.unshift(tool_path) unless $LOAD_PATH.include?(tool_path)
require "catalog_tools"

class CatalogToolsTest < RGSSI18nTestCase
  def sample_catalog
    {
      "battle" => {
        "wild_appeared" => "A wild {pokemon} appeared!",
        "colored" => "\\c[2]{name}\\c[0]"
      }
    }
  end

  def test_flatten_and_unflatten_round_trip
    flat = RGSSI18nTools::CatalogTools.flatten(sample_catalog)

    assert_equal("A wild {pokemon} appeared!", flat["battle.wild_appeared"])
    assert_equal(sample_catalog, RGSSI18nTools::CatalogTools.unflatten(flat))
  end

  def test_pseudolocalization_preserves_placeholders_and_control_codes
    pseudo = RGSSI18nTools::CatalogTools.pseudolocalize_catalog(sample_catalog)

    assert(pseudo["battle"]["wild_appeared"].index("{pokemon}"))
    assert(pseudo["battle"]["wild_appeared"].index("["))
    assert(pseudo["battle"]["colored"].index("\\c"))
    assert(pseudo["battle"]["colored"].index("{name}"))
  end

  def test_simplelocalize_multi_language_profile_round_trips
    exported = RGSSI18nTools::CatalogTools.export_profile("simplelocalize_multi_language_json", "en", sample_catalog)
    imported = RGSSI18nTools::CatalogTools.import_profile("simplelocalize_multi_language_json", "en", exported)

    assert_equal({"en" => "A wild {pokemon} appeared!"}, exported["battle.wild_appeared"])
    assert_equal(sample_catalog, imported)
  end

  def test_xliff_profile_round_trips
    exported = RGSSI18nTools::CatalogTools.export_profile("xliff", "fr", sample_catalog)
    imported = RGSSI18nTools::CatalogTools.import_profile("xliff", "fr", exported)

    assert(exported.index("<xliff"))
    assert_equal(sample_catalog, imported)
  end

  def test_po_profile_round_trips
    exported = RGSSI18nTools::CatalogTools.export_profile("po", "fr", sample_catalog)
    imported = RGSSI18nTools::CatalogTools.import_profile("po", "fr", exported)

    assert(exported.index("msgctxt"))
    assert_equal(sample_catalog, imported)
  end

  def test_json_writer_output_can_be_reloaded
    path = File.join(File.dirname(__FILE__), "tmp_catalog_tools.json")
    RGSSI18nTools::CatalogTools.write_json(path, sample_catalog)

    assert_equal(sample_catalog, RGSSI18nTools::CatalogTools.load_json(path))
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_pbs_builds_data_catalog
    path = File.join(File.dirname(__FILE__), "tmp_moves.txt")
    File.open(path, "wb") do |file|
      file.write("# comment\n")
      file.write("69,THUNDERBOLT,Thunderbolt,007,95,ELECTRIC,Special,100,15,10,00,0,bef,\"A strong electric blast.\"\n")
    end

    catalog = RGSSI18nTools::CatalogTools.extract_pbs("moves", path)

    assert_equal("Thunderbolt", catalog["data"]["moves"]["thunderbolt"]["name"])
    assert_equal("A strong electric blast.", catalog["data"]["moves"]["thunderbolt"]["description"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_import_text_english_builds_sectioned_source_text_catalog
    path = File.join(File.dirname(__FILE__), "fixtures", "text_english", "sample.txt")
    catalog = RGSSI18nTools::CatalogTools.import_text_english(path, "text")

    assert_equal("text.map0.line_0001", catalog["source_text"]["Hello traveler"])
    assert_equal("Hello traveler", catalog["text"]["map0"]["line_0001"])
    assert_equal("Buy potions", catalog["text"]["shop"]["line_0001"])
  end

  def test_import_text_english_dir_merges_files
    dir = File.join(File.dirname(__FILE__), "fixtures", "text_english")
    catalog = RGSSI18nTools::CatalogTools.import_text_english_dir(dir, "bundle")

    assert_equal("Hello traveler", catalog["bundle"]["sample"]["map0"]["line_0001"])
    assert_equal("bundle.sample.shop.line_0001", catalog["source_text"]["Buy potions"])
  end

  def test_extract_map_rxdata_reads_show_text_commands
    path = write_map_rxdata_fixture("Map001.rxdata")
    extracted = RGSSI18nTools::CatalogTools.extract_map_rxdata(path)

    assert_equal("rpg_maker_xp_map", extracted["format"])
    assert_equal("map_0001", extracted["map_id"])
    assert_equal("Hello there.", extracted["events"]["event_0001"]["pages"]["page_01"]["commands"][0]["lines"][0])
    assert_equal("Welcome to the shop.", extracted["events"]["event_0001"]["pages"]["page_01"]["commands"][1]["lines"][0])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_import_map_rxdata_builds_runtime_catalog
    path = write_map_rxdata_fixture("Map001.rxdata")
    catalog = RGSSI18nTools::CatalogTools.import_map_rxdata(path, "maps")

    assert_equal("maps.maps.map_0001.event_0001.line_0001", catalog["source_text"]["Hello there."])
    assert_equal("Hello there.", catalog["maps"]["maps"]["map_0001"]["event_0001"]["line_0001"])
    assert_equal("Welcome to the shop.", catalog["maps"]["maps"]["map_0001"]["event_0001"]["line_0002"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_import_essentials_pairs_builds_source_text_catalog
    path = File.join(File.dirname(__FILE__), "tmp_intl.txt")
    File.open(path, "wb") do |file|
      file.write("# comment\n")
      file.write("A wild {1} appeared!\n")
      file.write("A wild {pokemon} appeared!\n")
    end

    catalog = RGSSI18nTools::CatalogTools.import_essentials_pairs(path, "essentials")

    assert_equal("essentials.line_0001", catalog["source_text"]["A wild {1} appeared!"])
    assert_equal("A wild {pokemon} appeared!", catalog["essentials"]["line_0001"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_messages_dat_reads_ordered_hash_sections
    path = write_messages_dat_fixture
    extracted = RGSSI18nTools::CatalogTools.extract_messages_dat(path)

    assert_equal("pokemon_essentials_messages_dat", extracted["format"])
    assert_equal("Hello {1}", extracted["sections"]["maps"]["maps"]["map_0000"]["line_0001"]["source"])
    assert_equal("Hola {1}", extracted["sections"]["maps"]["maps"]["map_0000"]["line_0001"]["target"])
    assert_equal("Bulbasaur", extracted["sections"]["species"]["entries"]["id_0001"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_migrate_messages_dat_builds_runtime_catalog
    path = write_messages_dat_fixture
    catalog = RGSSI18nTools::CatalogTools.migrate_messages_dat(path, "legacy")

    assert_equal("legacy.maps.map_0000.line_0001", catalog["source_text"]["Hello {1}"])
    assert_equal("Hola {arg1}", catalog["legacy"]["maps"]["map_0000"]["line_0001"])
    assert_equal("{arg1}''{arg2}\" #'{'colorQuest(", catalog["legacy"]["maps"]["map_0000"]["line_0002"])
    assert_equal("Bulbasaur", catalog["legacy"]["species"]["id_0001"])
    RGSSI18n.load_hash("en", catalog)
    assert_equal("Hola Oak", RGSSI18n.t("legacy.maps.map_0000.line_0001", {"arg1" => "Oak"}))
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_write_handoff_package_creates_translator_files
    source = File.join(File.dirname(__FILE__), "tmp_source_catalog.json")
    output = File.join(File.dirname(__FILE__), "tmp_handoff")
    RGSSI18nTools::CatalogTools.write_json(source, sample_catalog)

    assert_equal(true, RGSSI18nTools::CatalogTools.write_handoff_package(output, "en", source, nil))
    assert(File.exist?(File.join(output, "README.md")))
    assert(File.exist?(File.join(output, "source.en.json")))
    assert(File.exist?(File.join(output, "flat.en.json")))
    assert(File.exist?(File.join(output, "pseudo.en.json")))
  ensure
    File.delete(source) if source && File.exist?(source)
    FileUtils.rm_rf(output) if output
  end

  def write_messages_dat_fixture
    path = File.join(File.dirname(__FILE__), "tmp_messages.dat")
    map_messages = OrderedHash.new
    map_messages["Hello {1}"] = "Hola {1}"
    map_messages["Code {1}"] = "{1}'{2}\" \#{colorQuest("
    data = [
      [map_messages],
      ["", "Bulbasaur"]
    ]
    File.open(path, "wb") { |file| file.write(Marshal.dump(data)) }
    path
  end

  def write_map_rxdata_fixture(filename)
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "tools", "rgss_rxdata_stubs"))
    path = File.join(File.dirname(__FILE__), filename)
    cmd1 = RPG::EventCommand.new(101, 0, ["", 0, 0, 2, "Hello there."])
    cmd2 = RPG::EventCommand.new(401, 0, ["Welcome to the shop."])
    page = RPG::Event::Page.new
    page.list = [cmd1, cmd2]
    event = RPG::Event.new
    event.id = 1
    event.name = "Guide"
    event.pages = [page]
    map = RPG::Map.new
    map.events = {1 => event}
    File.open(path, "wb") { |file| file.write(Marshal.dump(map)) }
    path
  end
end
