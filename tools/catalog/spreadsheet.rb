kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

module KotobaTools
  module CatalogTools
    SPREADSHEET_HEADERS = ["key", "english", "translation", "context", "notes"]

    def self.spreadsheet_export(source_catalog, locale_catalog, metadata)
      source_flat = flatten(source_catalog)
      locale_flat = locale_catalog ? flatten(locale_catalog) : {}
      meta = metadata.is_a?(Hash) ? metadata : {}
      csv = write_csv_row(SPREADSHEET_HEADERS)
      translator_export_keys(source_flat).sort.each do |key|
        context = metadata_field(meta, key, "context")
        context = spreadsheet_context_for_key(key) if context == ""
        csv << write_csv_row([
          key,
          source_flat[key],
          locale_flat[key] || "",
          context,
          spreadsheet_notes(meta, key)
        ])
      end
      csv
    end

    def self.spreadsheet_import(source_catalog, csv_source)
      source_flat = flatten(source_catalog)
      rows = parse_csv(csv_source)
      raise ArgumentError, "spreadsheet is empty" if rows.empty?
      indices = spreadsheet_column_indices(rows.shift)
      flat = {}
      rows.each do |row|
        key = row[indices[:key]].to_s
        next if key == ""
        translation = row[indices[:translation]]
        next if translation.nil? || translation.strip == ""
        unless source_flat.has_key?(key)
          raise ArgumentError, "unknown spreadsheet key " + key
        end
        flat[key] = translation
      end
      unflatten(flat)
    end

    def self.translator_export_keys(flat)
      flat.keys.reject do |key|
        key == "source_text" || key[0, 12] == "source_text."
      end
    end

    def self.spreadsheet_context_for_key(key)
      parts = key.split(".")
      if parts[0] == "data" && parts.length >= 3
        return humanize_token(parts[1]) + " / " + parts[2..-1].join(" / ")
      end
      if parts.length >= 2
        return humanize_token(parts[0]) + " / " + parts[1..-1].join(" / ")
      end
      key
    end

    def self.humanize_token(value)
      value.to_s.gsub("_", " ").capitalize
    end

    def self.metadata_field(metadata, key, field)
      entry = metadata[key]
      return "" unless entry.is_a?(Hash)
      value = entry[field.to_s]
      value.is_a?(String) ? value : ""
    end

    def self.spreadsheet_notes(metadata, key)
      entry = metadata[key]
      return "" unless entry.is_a?(Hash)
      parts = []
      parts << entry["description"] if entry["description"].is_a?(String) && entry["description"] != ""
      if entry["speaker"].is_a?(String) && entry["speaker"] != ""
        parts << "Speaker: " + entry["speaker"]
      end
      if entry["max_length"].is_a?(Integer)
        parts << "Max length: " + entry["max_length"].to_s
      end
      parts.join(" | ")
    end

    def self.spreadsheet_column_indices(header)
      normalized = {}
      header.each_with_index do |name, index|
        normalized[name.to_s.downcase.strip] = index
      end
      missing = ["key", "translation"].reject { |name| normalized.has_key?(name) }
      unless missing.empty?
        raise ArgumentError, "spreadsheet is missing required columns: " + missing.join(", ")
      end
      {
        :key => normalized["key"],
        :translation => normalized["translation"]
      }
    end

    def self.format_csv_field(value)
      text = value.to_s
      if text.index(",") || text.index("\"") || text.index("\n") || text.index("\r")
        return "\"" + text.gsub("\"", "\"\"") + "\""
      end
      text
    end

    def self.write_csv_row(fields)
      fields.collect { |field| format_csv_field(field) }.join(",") + "\n"
    end

    def self.parse_csv(source)
      text = source.to_s
      text = text[1, text.length - 1] if text[0, 3] == "\xEF\xBB\xBF"
      rows = []
      text.split(/\n/).each do |line|
        trimmed = line.strip
        next if trimmed == ""
        rows << split_csv_line(line.chomp)
      end
      rows
    end
  end
end
