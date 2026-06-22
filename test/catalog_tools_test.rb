require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))
require "fileutils"

tool_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "tools"))
$LOAD_PATH.unshift(tool_path) unless $LOAD_PATH.include?(tool_path)
require "catalog_tools"

class CatalogToolsTest < KotobaTestCase
  def sample_catalog
    {
      "battle" => {
        "wild_appeared" => "A wild {pokemon} appeared!",
        "colored" => "\\c[2]{name}\\c[0]"
      }
    }
  end

  def test_flatten_and_unflatten_round_trip
    flat = KotobaTools::CatalogTools.flatten(sample_catalog)

    assert_equal("A wild {pokemon} appeared!", flat["battle.wild_appeared"])
    assert_equal(sample_catalog, KotobaTools::CatalogTools.unflatten(flat))
  end

  def test_pseudolocalization_preserves_placeholders_and_control_codes
    pseudo = KotobaTools::CatalogTools.pseudolocalize_catalog(sample_catalog)

    assert(pseudo["battle"]["wild_appeared"].index("{pokemon}"))
    assert(pseudo["battle"]["wild_appeared"].index("["))
    assert(pseudo["battle"]["colored"].index("\\c"))
    assert(pseudo["battle"]["colored"].index("{name}"))
  end

  def test_simplelocalize_multi_language_profile_round_trips
    exported = KotobaTools::CatalogTools.export_profile("simplelocalize_multi_language_json", "en", sample_catalog)
    imported = KotobaTools::CatalogTools.import_profile("simplelocalize_multi_language_json", "en", exported)

    assert_equal({"en" => "A wild {pokemon} appeared!"}, exported["battle.wild_appeared"])
    assert_equal(sample_catalog, imported)
  end

  def test_xliff_profile_round_trips
    exported = KotobaTools::CatalogTools.export_profile("xliff", "fr", sample_catalog)
    imported = KotobaTools::CatalogTools.import_profile("xliff", "fr", exported)

    assert(exported.index("<xliff"))
    assert_equal(sample_catalog, imported)
  end

  def test_po_profile_round_trips
    exported = KotobaTools::CatalogTools.export_profile("po", "fr", sample_catalog)
    imported = KotobaTools::CatalogTools.import_profile("po", "fr", exported)

    assert(exported.index("msgctxt"))
    assert_equal(sample_catalog, imported)
  end

  def test_json_writer_output_can_be_reloaded
    path = File.join(File.dirname(__FILE__), "tmp_catalog_tools.json")
    KotobaTools::CatalogTools.write_json(path, sample_catalog)

    assert_equal(sample_catalog, KotobaTools::CatalogTools.load_json(path))
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_pbs_builds_data_catalog
    path = File.join(File.dirname(__FILE__), "tmp_moves.txt")
    File.open(path, "wb") do |file|
      file.write("# comment\n")
      file.write("69,THUNDERBOLT,Thunderbolt,007,95,ELECTRIC,Special,100,15,10,00,0,bef,\"A strong electric blast.\"\n")
    end

    catalog = KotobaTools::CatalogTools.extract_pbs("moves", path)

    assert_equal("Thunderbolt", catalog["data"]["moves"]["thunderbolt"]["name"])
    assert_equal("A strong electric blast.", catalog["data"]["moves"]["thunderbolt"]["description"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_pbs_items_profile_includes_plural_name
    path = File.join(File.dirname(__FILE__), "tmp_items.txt")
    File.open(path, "wb") do |file|
      file.write("1,POTION,Potion,Potions,1,200,\"Restores 20 HP.\",2,0,0,\n")
    end

    catalog = KotobaTools::CatalogTools.extract_pbs("items", path)

    assert_equal("Potion", catalog["data"]["items"]["potion"]["name"])
    assert_equal("Potions", catalog["data"]["items"]["potion"]["name_plural"])
    assert_equal("Restores 20 HP.", catalog["data"]["items"]["potion"]["description"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_pbs_abilities_profile_extracts_description
    path = File.join(File.dirname(__FILE__), "tmp_abilities.txt")
    File.open(path, "wb") do |file|
      file.write("1,OVERGROW,Overgrow,\"Powers up Grass moves in a pinch.\"\n")
    end

    catalog = KotobaTools::CatalogTools.extract_pbs("abilities", path)

    assert_equal("Overgrow", catalog["data"]["abilities"]["overgrow"]["name"])
    assert_equal("Powers up Grass moves in a pinch.", catalog["data"]["abilities"]["overgrow"]["description"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_import_text_english_builds_sectioned_source_text_catalog
    path = File.join(File.dirname(__FILE__), "fixtures", "text_english", "sample.txt")
    catalog = KotobaTools::CatalogTools.import_text_english(path, "text")

    assert_equal("text.map0.line_0001", catalog["source_text"]["Hello traveler"])
    assert_equal("Hello traveler", catalog["text"]["map0"]["line_0001"])
    assert_equal("Buy potions", catalog["text"]["shop"]["line_0001"])
  end

  def test_import_text_english_dir_merges_files
    dir = File.join(File.dirname(__FILE__), "fixtures", "text_english")
    catalog = KotobaTools::CatalogTools.import_text_english_dir(dir, "bundle")

    assert_equal("Hello traveler", catalog["bundle"]["sample"]["map0"]["line_0001"])
    assert_equal("bundle.sample.shop.line_0001", catalog["source_text"]["Buy potions"])
  end

  def test_extract_map_rxdata_reads_show_text_commands
    path = write_map_rxdata_fixture("Map001.rxdata")
    extracted = KotobaTools::CatalogTools.extract_map_rxdata(path)

    assert_equal("rpg_maker_xp_map", extracted["format"])
    assert_equal("map_0001", extracted["map_id"])
    commands = extracted["events"]["event_0001"]["pages"]["page_01"]["commands"]
    assert_equal("Hello there.", commands[0]["lines"][0])
    assert_equal("Welcome to the shop.", commands[1]["lines"][0])
    assert_equal(["Option A", "Option B"], commands[2]["lines"])
    assert_equal(["Option A"], commands[3]["lines"])
    assert_equal(["Check the path ahead."], commands[4]["lines"])
    assert_equal(["Checkpoint ahead."], commands[5]["lines"])
    assert_equal(["Trail marker noted."], commands[6]["lines"])
    assert_equal(["Warp engaged."], commands[7]["lines"])
    assert_equal(["Gate opens."], commands[8]["lines"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_import_map_rxdata_builds_runtime_catalog
    path = write_map_rxdata_fixture("Map001.rxdata")
    catalog = KotobaTools::CatalogTools.import_map_rxdata(path, "maps")

    assert_equal("maps.maps.map_0001.event_0001.line_0001", catalog["source_text"]["Hello there."])
    assert_equal("Hello there.", catalog["maps"]["maps"]["map_0001"]["event_0001"]["line_0001"])
    assert_equal("Option A", catalog["maps"]["maps"]["map_0001"]["event_0001"]["line_0003"])
    assert_equal("Option A", catalog["maps"]["maps"]["map_0001"]["event_0001"]["line_0005"])
    assert_equal("Check the path ahead.", catalog["maps"]["maps"]["map_0001"]["event_0001"]["line_0006"])
    assert_equal("Checkpoint ahead.", catalog["maps"]["maps"]["map_0001"]["event_0001"]["line_0007"])
    assert_equal("Trail marker noted.", catalog["maps"]["maps"]["map_0001"]["event_0001"]["line_0008"])
    assert_equal("Gate opens.", catalog["maps"]["maps"]["map_0001"]["event_0001"]["line_0010"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_pbs_pokemon_sections_extract_translatable_fields
    path = File.join(File.dirname(__FILE__), "tmp_pokemon.txt")
    File.open(path, "wb") do |file|
      file.write("[9001]\n")
      file.write("Name=Sproutling\n")
      file.write("InternalName=SPROUTLING\n")
      file.write("Kind=Seed\n")
      file.write("Pokedex=A small creature.\n")
    end

    catalog = KotobaTools::CatalogTools.extract_pbs("pokemon", path)

    assert_equal("Sproutling", catalog["data"]["pokemon"]["sproutling"]["name"])
    assert_equal("Seed", catalog["data"]["pokemon"]["sproutling"]["kind"])
    assert_equal("A small creature.", catalog["data"]["pokemon"]["sproutling"]["pokedex"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_pbs_types_sections_extract_names
    path = File.join(File.dirname(__FILE__), "tmp_types.txt")
    File.open(path, "wb") do |file|
      file.write("[NORMAL]\n")
      file.write("Name=Normal\n")
      file.write("[GRASS]\n")
      file.write("Name=Grass\n")
    end

    catalog = KotobaTools::CatalogTools.extract_pbs("types", path)

    assert_equal("Normal", catalog["data"]["types"]["normal"]["name"])
    assert_equal("Grass", catalog["data"]["types"]["grass"]["name"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_pbs_trainers_sections_extract_battle_text
    path = File.join(File.dirname(__FILE__), "tmp_trainers.txt")
    File.open(path, "wb") do |file|
      file.write("[GUIDE,Aria]\n")
      file.write("LoseText=You know the trail well.\n")
      file.write("[SCOUT,Ren,1]\n")
      file.write("LoseText=Still not enough.\n")
      file.write("RegSpeech=Take this map.\n")
    end

    catalog = KotobaTools::CatalogTools.extract_pbs("trainers", path)

    guide = catalog["data"]["trainers"]["guide_aria"]
    assert_equal("GUIDE", guide["trainer_type"])
    assert_equal("Aria", guide["trainer_name"])
    assert_equal("You know the trail well.", guide["lose_text"])

    scout = catalog["data"]["trainers"]["scout_ren_1"]
    assert_equal("1", scout["version"])
    assert_equal("Take this map.", scout["reg_speech"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_pbs_trainer_types_sections_extract_names
    path = File.join(File.dirname(__FILE__), "tmp_trainer_types.txt")
    File.open(path, "wb") do |file|
      file.write("[GUIDE]\n")
      file.write("Name=Guide\n")
      file.write("InternalName=GUIDE\n")
    end

    catalog = KotobaTools::CatalogTools.extract_pbs("trainer_types", path)

    assert_equal("Guide", catalog["data"]["trainer_types"]["guide"]["name"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_pbs_map_metadata_sections_extract_names
    path = File.join(File.dirname(__FILE__), "tmp_map_metadata.txt")
    File.open(path, "wb") do |file|
      file.write("[001]\n")
      file.write("Name=Town Square\n")
    end

    catalog = KotobaTools::CatalogTools.extract_pbs("map_metadata", path)

    assert_equal("Town Square", catalog["data"]["map_metadata"]["001"]["name"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_event_command_text_handles_nested_choice_arrays
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "tools", "rgss_rxdata_stubs"))
    command = RPG::EventCommand.new(102, 0, [["Yes", "No"], 2])
    lines = KotobaTools::CatalogTools.extract_event_command_text(command)

    assert_equal(["Yes", "No"], lines)
  end

  def test_extract_event_command_text_handles_choice_branch_and_comment_more
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "tools", "rgss_rxdata_stubs"))
    branch = RPG::EventCommand.new(402, 0, [0, "Yes"])
    comment = RPG::EventCommand.new(408, 0, ["More notes."])

    assert_equal(["Yes"], KotobaTools::CatalogTools.extract_event_command_text(branch))
    assert_equal(["More notes."], KotobaTools::CatalogTools.extract_event_command_text(comment))
  end

  def test_import_essentials_pairs_builds_source_text_catalog
    path = File.join(File.dirname(__FILE__), "tmp_intl.txt")
    File.open(path, "wb") do |file|
      file.write("# comment\n")
      file.write("A wild {1} appeared!\n")
      file.write("A wild {pokemon} appeared!\n")
    end

    catalog = KotobaTools::CatalogTools.import_essentials_pairs(path, "essentials")

    assert_equal("essentials.line_0001", catalog["source_text"]["A wild {1} appeared!"])
    assert_equal("A wild {pokemon} appeared!", catalog["essentials"]["line_0001"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_extract_messages_dat_reads_ordered_hash_sections
    path = write_messages_dat_fixture
    extracted = KotobaTools::CatalogTools.extract_messages_dat(path)

    assert_equal("pokemon_essentials_messages_dat", extracted["format"])
    assert_equal("Hello {1}", extracted["sections"]["maps"]["maps"]["map_0000"]["line_0001"]["source"])
    assert_equal("Hola {1}", extracted["sections"]["maps"]["maps"]["map_0000"]["line_0001"]["target"])
    assert_equal("Bulbasaur", extracted["sections"]["species"]["entries"]["id_0001"])
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_migrate_messages_dat_builds_runtime_catalog
    path = write_messages_dat_fixture
    catalog = KotobaTools::CatalogTools.migrate_messages_dat(path, "legacy")

    assert_equal("legacy.maps.map_0000.line_0001", catalog["source_text"]["Hello {1}"])
    assert_equal("Hola {arg1}", catalog["legacy"]["maps"]["map_0000"]["line_0001"])
    assert_equal("{arg1}''{arg2}\" #'{'colorQuest(", catalog["legacy"]["maps"]["map_0000"]["line_0002"])
    assert_equal("Bulbasaur", catalog["legacy"]["species"]["id_0001"])
    Kotoba.load_hash("en", catalog)
    assert_equal("Hola Oak", Kotoba.t("legacy.maps.map_0000.line_0001", {"arg1" => "Oak"}))
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  def test_write_handoff_package_creates_translator_files
    source = File.join(File.dirname(__FILE__), "tmp_source_catalog.json")
    output = File.join(File.dirname(__FILE__), "tmp_handoff")
    KotobaTools::CatalogTools.write_json(source, sample_catalog)

    assert_equal(true, KotobaTools::CatalogTools.write_handoff_package(output, "en", source, nil))
    assert(File.exist?(File.join(output, "README.md")))
    assert(File.exist?(File.join(output, "source.en.json")))
    assert(File.exist?(File.join(output, "flat.en.json")))
    assert(File.exist?(File.join(output, "pseudo.en.json")))
    assert(File.exist?(File.join(output, "spreadsheet.en.csv")))
  ensure
    File.delete(source) if source && File.exist?(source)
    FileUtils.rm_rf(output) if output
  end

  def test_spreadsheet_export_and_import_round_trip
    metadata = {
      "battle.wild_appeared" => {
        "context" => "Wild battle intro",
        "description" => "Shown when a wild Pokemon appears."
      }
    }
    locale = {
      "battle" => {
        "wild_appeared" => "Un {pokemon} sauvage apparait !"
      }
    }
    csv = KotobaTools::CatalogTools.spreadsheet_export(sample_catalog, locale, metadata)
    imported = KotobaTools::CatalogTools.spreadsheet_import(sample_catalog, csv)

    assert(csv.index("key,english,translation,context,notes"))
    assert(csv.index("Wild battle intro"))
    assert_equal("Un {pokemon} sauvage apparait !", imported["battle"]["wild_appeared"])
  end

  def test_spreadsheet_import_rejects_unknown_keys
    csv = "key,english,translation,context,notes\nmissing.key,Hello,Hola,,\n"
    raised = false
    begin
      KotobaTools::CatalogTools.spreadsheet_import(sample_catalog, csv)
    rescue ArgumentError
      raised = true
    end
    assert_equal(true, raised)
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
    cmd3 = RPG::EventCommand.new(102, 0, [["Option A", "Option B"], 2])
    cmd4 = RPG::EventCommand.new(402, 0, [0, "Option A"])
    cmd5 = RPG::EventCommand.new(355, 0, ["pbMessage(_INTL(\"Check the path ahead.\"))"])
    cmd6 = RPG::EventCommand.new(108, 0, ["Checkpoint ahead."])
    cmd7 = RPG::EventCommand.new(408, 0, ["Trail marker noted."])
    cmd8 = RPG::EventCommand.new(356, 0, ["pbMessage(_ISPRINTF(\"Warp engaged.\"))"])
    cmd9 = RPG::EventCommand.new(657, 0, ["pbMessage(_INTL('Gate opens.'))"])
    page = RPG::Event::Page.new
    page.list = [cmd1, cmd2, cmd3, cmd4, cmd5, cmd6, cmd7, cmd8, cmd9]
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
