require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

project_root = File.expand_path("..", File.dirname(__FILE__))
tool_path = File.join(project_root, "tools")
$LOAD_PATH.unshift(tool_path) unless $LOAD_PATH.include?(tool_path)
require "local_fixture_config"

class LocalIntegrationTest < KotobaTestCase
  def test_local_fixture_config_is_optional
    config = LocalFixtureConfig.load()
    assert(config["games"].is_a?(Hash))
    assert_nil(LocalFixtureConfig.game_path("missing"))
  end

  def test_local_essentials_bes_sample_runs_migration_trio
    path = LocalFixtureConfig.game_path("essentials_bes_sample")
    return unless path && File.directory?(path)

    messages_dat = File.join(path, "Data", "messages.dat")
    intl = File.join(path, "intl.txt")
    moves = File.join(path, "PBS", "moves.txt")

    assert(File.directory?(path), "configured game path must exist")
    assert(File.file?(messages_dat), "messages.dat must exist")
    assert(File.file?(intl), "intl.txt must exist")
    assert(File.file?(moves), "PBS/moves.txt must exist")

    require "catalog_tools"
    assert(KotobaTools::CatalogTools.extract_messages_dat(messages_dat))
    assert(KotobaTools::CatalogTools.migrate_messages_dat(messages_dat, "local_sample"))
    assert(KotobaTools::CatalogTools.import_essentials_pairs(intl, "local_sample"))
    assert(KotobaTools::CatalogTools.extract_pbs("moves", moves))
  end

  def test_local_text_english_import_when_present
    path = LocalFixtureConfig.game_path("essentials_bes_sample")
    return unless path && File.directory?(path)

    core = File.join(path, "Text_english_core")
    return unless File.directory?(core)

    require "catalog_tools"
    catalog = KotobaTools::CatalogTools.import_text_english_dir(core, "local_core")
    assert(!catalog.empty?)
  end

  def test_local_map_rxdata_import_when_present
    path = LocalFixtureConfig.game_path("essentials_bes_sample")
    return unless path && File.directory?(path)

    map_path = File.join(path, "Data", "Map001.rxdata")
    return unless File.file?(map_path)

    require "catalog_tools"
    catalog = KotobaTools::CatalogTools.import_map_rxdata(map_path, "local_maps")
    assert(!catalog.empty?)
  end

  def test_local_pokemon_pbs_extract_when_present
    path = LocalFixtureConfig.game_path("essentials_bes_sample")
    return unless path && File.directory?(path)

    pokemon = File.join(path, "PBS", "pokemon.txt")
    return unless File.file?(pokemon)

    require "catalog_tools"
    catalog = KotobaTools::CatalogTools.extract_pbs("pokemon", pokemon)
    assert(!catalog["data"]["pokemon"].empty?)
  end

  def test_local_map_sample_set_has_no_extractable_text_gaps
    path = LocalFixtureConfig.game_path("essentials_bes_sample")
    return unless path && File.directory?(path)

    require "catalog_tools"
    require "rgss_rxdata_stubs"
    map_paths = [File.join(path, "Data", "Map001.rxdata")]
    map_paths.each do |map_path|
      next unless File.file?(map_path)
      map = Marshal.load(File.binread(map_path))
      next unless map && map.events
      map.events.each do |_, event|
        next unless event && event.pages
        event.pages.each do |page|
          next unless page && page.list
          page.list.each do |command|
            next unless command
            extracted = KotobaTools::CatalogTools.extract_event_command_text(command)
            next unless extracted.empty?
            params = command.parameters || []
            next unless params.any? { |param| param.is_a?(String) && param.to_s.strip != "" }
            next if [111, 118, 119, 204, 231].include?(command.code)
            flunk("unextracted text in command #{command.code}: #{params.inspect}")
          end
        end
      end
    end
  end
end
