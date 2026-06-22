require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper"))

adapter_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "adapters"))
$LOAD_PATH.unshift(adapter_path) unless $LOAD_PATH.include?(adapter_path)
require "essentials_v16"
require "essentials_v17"
require "essentials_v18"
require "essentials_v19_v20"
require "essentials_v21"
require "essentials_bes"

class EssentialsAdapterTest < RGSSI18nTestCase
  FIXTURE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "fixtures", "essentials"))

  def fixture(*parts)
    File.join(FIXTURE_ROOT, *parts)
  end

  def test_v19_v20_intl_bridge_uses_source_map_fixture
    RGSSI18n.use_adapter("essentials_v19_v20", {
      "catalog_paths" => {"en" => [fixture("v19_v20", "source_map.json")]},
      "load" => true
    })

    assert_equal("A wild Pikachu appeared!", RGSSI18n::Adapters::EssentialsV19V20._INTL("A wild {1} appeared!", "Pikachu"))
  end

  def test_v16_intl_bridge_uses_source_map_fixture
    RGSSI18n.use_adapter("essentials_v16", {
      "catalog_paths" => {"en" => [fixture("v16", "source_map.json")]},
      "load" => true
    })

    assert_equal("A wild Eevee appeared!", RGSSI18n::Adapters::EssentialsV16._INTL("A wild {1} appeared!", "Eevee"))
  end

  def test_v17_intl_bridge_uses_local_package_fixture
    RGSSI18n.use_adapter("essentials_v17", {
      "catalog_paths" => {"en" => [fixture("v17", "source_map.json")]},
      "load" => true
    })

    assert_equal("A wild Mew appeared!", RGSSI18n::Adapters::EssentialsV17._INTL("A wild {1} appeared!", "Mew"))
  end

  def test_v18_intl_bridge_uses_local_package_fixture
    RGSSI18n.use_adapter("essentials_v18", {
      "catalog_paths" => {"en" => [fixture("v18", "source_map.json")]},
      "load" => true
    })

    assert_equal("A wild Lugia appeared!", RGSSI18n::Adapters::EssentialsV18._INTL("A wild {1} appeared!", "Lugia"))
    assert_equal("You have 42 coins.", RGSSI18n::Adapters::EssentialsV18._ISPRINTF("You have {1:d} coins.", 42))
  end

  def test_v21_loads_core_and_game_split_fixture
    RGSSI18n.use_adapter("essentials_v21", {
      "catalog_paths" => {
        "en" => [
          fixture("v21", "messages_core.json"),
          fixture("v21", "messages_game.json")
        ]
      },
      "load" => true
    })

    assert_equal("Save", RGSSI18n.t("core.menu.save"))
    assert_equal("A wild Mew appeared!", RGSSI18n.t("game.battle.wild_appeared", {"pokemon" => "Mew"}))
  end

  def test_bes_data_lookup_uses_localization_fixture
    RGSSI18n.use_adapter("essentials_bes", {
      "catalog_paths" => {"en" => [fixture("bes", "localization.json")]},
      "load" => true
    })

    assert_equal("Thunderbolt", RGSSI18n::Adapters::EssentialsBES.move_name("thunderbolt"))
    assert_equal("Potion", RGSSI18n::Adapters::EssentialsBES.item_name("potion"))
    assert_equal("Overgrow", RGSSI18n::Adapters::EssentialsBES.ability_name("overgrow"))
  end

  def test_all_fixture_backed_essentials_adapters_are_registered
    names = RGSSI18n.available_adapters

    assert(names.include?("essentials_v16"))
    assert(names.include?("essentials_v17"))
    assert(names.include?("essentials_v18"))
    assert(names.include?("essentials_v19"))
    assert(names.include?("essentials_v20"))
    assert(names.include?("essentials_v19_v20"))
    assert(names.include?("essentials_v21"))
    assert(names.include?("essentials_bes"))
  end

  def test_v19_and_v20_names_use_shared_fixture_backed_adapter
    options = {
      "catalog_paths" => {"en" => [fixture("v19_v20", "source_map.json")]},
      "load" => true
    }

    RGSSI18n.use_adapter("essentials_v19", options)
    assert_equal("A wild Pidgey appeared!", RGSSI18n::Adapters::EssentialsV19V20._INTL("A wild {1} appeared!", "Pidgey"))

    RGSSI18n.reset!
    RGSSI18n.use_adapter("essentials_v20", options)
    assert_equal("A wild Rattata appeared!", RGSSI18n::Adapters::EssentialsV19V20._INTL("A wild {1} appeared!", "Rattata"))
  end

  def test_essentials_global_patch_is_opt_in
    RGSSI18n.use_adapter("essentials_v18", {
      "catalog_paths" => {"en" => [fixture("v18", "source_map.json")]},
      "load" => true,
      "install_global" => true,
      "force_global" => true
    })

    assert_equal("A wild Ho-Oh appeared!", _INTL("A wild {1} appeared!", "Ho-Oh"))
  end
end
