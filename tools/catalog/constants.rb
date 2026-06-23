kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

module KotobaTools
  module CatalogTools
    ACCENTS = {
      "a" => "a", "b" => "b", "c" => "c", "d" => "d", "e" => "e",
      "f" => "f", "g" => "g", "h" => "h", "i" => "i", "j" => "j",
      "k" => "k", "l" => "l", "m" => "m", "n" => "n", "o" => "o",
      "p" => "p", "q" => "q", "r" => "r", "s" => "s", "t" => "t",
      "u" => "u", "v" => "v", "w" => "w", "x" => "x", "y" => "y",
      "z" => "z"
    }
    MESSAGE_SECTION_NAMES = [
      "maps",
      "species",
      "kinds",
      "entries",
      "form_names",
      "moves",
      "move_descriptions",
      "items",
      "item_plurals",
      "item_descriptions",
      "abilities",
      "ability_descriptions",
      "types",
      "trainer_types",
      "trainer_names",
      "begin_speech",
      "end_speech_win",
      "end_speech_lose",
      "region_names",
      "place_names",
      "place_descriptions",
      "map_names",
      "phone_messages",
      "script_texts"
    ]
    MESSAGE_SECTION_NAMES_V18 = MESSAGE_SECTION_NAMES[0, 23] + ["trainer_lose_text", "script_texts"]
    PBS_PROFILES = {
      "moves" => {"name" => 2, "description" => -1},
      "items" => {"name" => 2, "name_plural" => 3, "description" => 6},
      "abilities" => {"name" => 2, "description" => 3}
    }
    PBS_SECTION_PROFILES = {
      "pokemon" => {
        "Name" => "name",
        "Kind" => "kind",
        "Pokedex" => "pokedex",
        "FormName" => "form_name"
      },
      "types" => {
        "Name" => "name"
      },
      "trainers" => {
        "LoseText" => "lose_text",
        "EndSpeech" => "end_speech",
        "EndBattle" => "end_battle",
        "RegSpeech" => "reg_speech"
      },
      "trainer_types" => {
        "Name" => "name"
      },
      "map_metadata" => {
        "Name" => "name"
      }
    }
  end
end
