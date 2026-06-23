kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

module KotobaTools
  module CatalogTools
    def self.write_handoff_package(output_dir, locale, source_path, metadata_path)
      catalog = load_json(source_path)
      metadata = metadata_path && File.file?(metadata_path) ? load_json(metadata_path) : nil
      FileUtils.mkdir_p(output_dir)
      write_json(File.join(output_dir, "source." + locale.to_s + ".json"), catalog)
      write_json(File.join(output_dir, "flat." + locale.to_s + ".json"), flatten(catalog))
      write_json(File.join(output_dir, "pseudo." + locale.to_s + ".json"), pseudolocalize_catalog(catalog))
      File.open(File.join(output_dir, "spreadsheet." + locale.to_s + ".csv"), "wb") do |file|
        file.write(spreadsheet_export(catalog, nil, metadata))
      end
      if metadata_path && File.file?(metadata_path)
        FileUtils.cp(metadata_path, File.join(output_dir, "metadata.json"))
      end
      File.open(File.join(output_dir, "README.md"), "wb") do |file|
        file.write("# Translation Handoff\n\n")
        file.write("- Source locale: `" + locale.to_s + "`\n")
        file.write("- `spreadsheet." + locale.to_s + ".csv`: open this in Google Sheets or Excel\n")
        file.write("- `source." + locale.to_s + ".json`: runtime catalog for developers\n")
        file.write("- `flat." + locale.to_s + ".json`: flat dot-key catalog\n")
        file.write("- `pseudo." + locale.to_s + ".json`: pseudolocalized QA catalog\n\n")
        file.write("Translators should edit only the `translation` column in the spreadsheet.\n")
        file.write("Do not remove placeholders like `{name}` or RPG Maker control codes like `\\\\c[2]`.\n")
      end
      true
    end
  end
end
