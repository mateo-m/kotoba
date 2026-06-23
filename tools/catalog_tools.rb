kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

CATALOG_MODULES = [
  "catalog/ordered_hash.rb",
  "catalog/constants.rb",
  "catalog/json_io.rb",
  "catalog/shape.rb",
  "catalog/pseudolocalize.rb",
  "catalog/format_profiles.rb",
  "catalog/spreadsheet.rb",
  "catalog/essentials_extractors.rb",
  "catalog/rgss_extractors.rb",
  "catalog/handoff.rb"
]

CATALOG_MODULES.each do |relative_path|
  require File.join(File.dirname(__FILE__), relative_path)
end
