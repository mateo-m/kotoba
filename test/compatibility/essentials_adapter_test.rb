require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper"))

adapter_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "adapters"))
$LOAD_PATH.unshift(adapter_path) unless $LOAD_PATH.include?(adapter_path)
require "essentials_v16"
require "essentials_v17"
require "essentials_v18"
require "essentials_v19"
require "essentials_v20"
require "essentials_v21"
require "essentials_bes"

class EssentialsAdapterTest < KotobaTestCase
  FIXTURE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "fixtures", "essentials"))

  def fixture(*parts)
    File.join(FIXTURE_ROOT, *parts)
  end

  def test_v19_intl_bridge_uses_source_map_fixture
    Kotoba.use_adapter("essentials_v19", {
      "catalog_paths" => {"en" => [fixture("v19_v20", "source_map.json")]},
      "load" => true
    })

    assert_equal("A wild Pikachu appeared!", Kotoba::Adapters::EssentialsV19._INTL("A wild {1} appeared!", "Pikachu"))
  end

  def test_v20_intl_bridge_uses_source_map_fixture
    Kotoba.use_adapter("essentials_v20", {
      "catalog_paths" => {"en" => [fixture("v19_v20", "source_map.json")]},
      "load" => true
    })

    assert_equal("A wild Rattata appeared!", Kotoba::Adapters::EssentialsV20._INTL("A wild {1} appeared!", "Rattata"))
  end

  def test_v16_intl_bridge_uses_source_map_fixture
    Kotoba.use_adapter("essentials_v16", {
      "catalog_paths" => {"en" => [fixture("v16", "source_map.json")]},
      "load" => true
    })

    assert_equal("A wild Eevee appeared!", Kotoba::Adapters::EssentialsV16._INTL("A wild {1} appeared!", "Eevee"))
  end

  def test_v17_intl_bridge_uses_local_package_fixture
    Kotoba.use_adapter("essentials_v17", {
      "catalog_paths" => {"en" => [fixture("v17", "source_map.json")]},
      "load" => true
    })

    assert_equal("A wild Mew appeared!", Kotoba::Adapters::EssentialsV17._INTL("A wild {1} appeared!", "Mew"))
  end

  def test_v18_intl_bridge_uses_local_package_fixture
    Kotoba.use_adapter("essentials_v18", {
      "catalog_paths" => {"en" => [fixture("v18", "source_map.json")]},
      "load" => true
    })

    assert_equal("A wild Lugia appeared!", Kotoba::Adapters::EssentialsV18._INTL("A wild {1} appeared!", "Lugia"))
    assert_equal("You have 42 coins.", Kotoba::Adapters::EssentialsV18._ISPRINTF("You have {1:d} coins.", 42))
  end

  def test_v21_loads_core_and_game_split_fixture
    Kotoba.use_adapter("essentials_v21", {
      "catalog_paths" => {
        "en" => [
          fixture("v21", "messages_core.json"),
          fixture("v21", "messages_game.json")
        ]
      },
      "load" => true
    })

    assert_equal("Save", Kotoba.t("core.menu.save"))
    assert_equal("A wild Mew appeared!", Kotoba.t("game.battle.wild_appeared", {"pokemon" => "Mew"}))
  end

  def test_bes_intl_bridge_uses_source_map_fixture
    Kotoba.use_adapter("essentials_bes", {
      "catalog_paths" => {"en" => [fixture("bes", "source_map.json")]},
      "load" => true
    })

    assert_equal("A wild Pikachu appeared!", Kotoba::Adapters::EssentialsBES._INTL("A wild {1} appeared!", "Pikachu"))
    assert_equal("You have 42 coins.", Kotoba::Adapters::EssentialsBES._ISPRINTF("You have {1:d} coins.", 42))
  end

  def test_bes_data_lookup_uses_localization_fixture
    Kotoba.use_adapter("essentials_bes", {
      "catalog_paths" => {"en" => [fixture("bes", "localization.json")]},
      "load" => true
    })

    assert_equal("Thunderbolt", Kotoba::Adapters::EssentialsBES.move_name("thunderbolt"))
    assert_equal("Potion", Kotoba::Adapters::EssentialsBES.item_name("potion"))
    assert_equal("Overgrow", Kotoba::Adapters::EssentialsBES.ability_name("overgrow"))
  end

  def test_all_fixture_backed_essentials_adapters_are_registered
    names = Kotoba.available_adapters

    assert(names.include?("essentials_v16"))
    assert(names.include?("essentials_v17"))
    assert(names.include?("essentials_v18"))
    assert(names.include?("essentials_v19"))
    assert(names.include?("essentials_v20"))
    assert(!names.include?("essentials_v19_v20"))
    assert(names.include?("essentials_v21"))
    assert(names.include?("essentials_bes"))
  end

  def test_v19_and_v20_are_separate_modules
    options = {
      "catalog_paths" => {"en" => [fixture("v19_v20", "source_map.json")]},
      "load" => true
    }

    Kotoba.use_adapter("essentials_v19", options)
    assert_equal("A wild Pidgey appeared!", Kotoba::Adapters::EssentialsV19._INTL("A wild {1} appeared!", "Pidgey"))

    Kotoba.reset!
    Kotoba.use_adapter("essentials_v20", {
      "catalog_paths" => {"en" => [fixture("v19_v20", "source_map.json")]},
      "load" => true
    })
    assert_equal("A wild Rattata appeared!", Kotoba::Adapters::EssentialsV20._INTL("A wild {1} appeared!", "Rattata"))
    assert(Kotoba::Adapters::EssentialsV19 != Kotoba::Adapters::EssentialsV20)
  end

  def test_essentials_global_patch_is_opt_in
    Kotoba.use_adapter("essentials_v18", {
      "catalog_paths" => {"en" => [fixture("v18", "source_map.json")]},
      "load" => true,
      "install_global" => true,
      "force_global" => true
    })

    assert_equal("A wild Ho-Oh appeared!", _INTL("A wild {1} appeared!", "Ho-Oh"))
  end
end
