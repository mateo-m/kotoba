require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

project_root = File.expand_path("..", File.dirname(__FILE__))
tool_path = File.join(project_root, "tools")
$LOAD_PATH.unshift(tool_path) unless $LOAD_PATH.include?(tool_path)
require "local_fixture_config"

class LocalIntegrationTest < RGSSI18nTestCase
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
    assert(RGSSI18nTools::CatalogTools.extract_messages_dat(messages_dat))
    assert(RGSSI18nTools::CatalogTools.migrate_messages_dat(messages_dat, "local_sample"))
    assert(RGSSI18nTools::CatalogTools.import_essentials_pairs(intl, "local_sample"))
    assert(RGSSI18nTools::CatalogTools.extract_pbs("moves", moves))
  end
end
