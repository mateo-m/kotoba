# Paste this entire file into a Script Editor section named "Kotoba".
# For kotoba-bare-rgss.zip (plain RPG Maker XP).
#
# On playtest you should see a message containing "Save".
# Remove the message block after Kotoba is confirmed working.

load "kotoba/boot.rb"

if defined?(Kotoba)
  msg = Kotoba.t("menu.save")
  if defined?(pbMessage)
    pbMessage("Kotoba says: " + msg)
  else
    print "Kotoba says: " + msg + "\n"
  end
end
