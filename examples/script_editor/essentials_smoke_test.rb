# Paste this entire file into a Script Editor section named "Kotoba".
# For Pokemon Essentials release ZIPs (v16–v21, BES).
#
# On playtest you should see: "A wild Pikachu appeared!"
# Remove the pbMessage block after Kotoba is confirmed working.

load "examples/boot_kotoba.rb"

if defined?(pbMessage) && defined?(Kotoba)
  pbMessage(Kotoba.t("battle.wild_appeared", {"pokemon" => "Pikachu"}))
end
