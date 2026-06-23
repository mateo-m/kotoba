kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

module KotobaTools
  module CatalogTools
    def self.export_profile(profile, locale, catalog)
      if profile == "flat_dot_keys"
        return flatten(catalog)
      end
      if profile == "simplelocalize_multi_language_json"
        result = {}
        flatten(catalog).each do |key, value|
          result[key] = {locale => value}
        end
        return result
      end
      return xliff(locale, catalog) if profile == "xliff"
      return po(catalog) if profile == "po"
      catalog
    end

    def self.import_profile(profile, locale, data)
      if profile == "flat_dot_keys"
        return unflatten(data)
      end
      if profile == "simplelocalize_multi_language_json"
        flat = {}
        data.each do |key, value|
          flat[key] = value[locale] if value.is_a?(Hash) && value.has_key?(locale)
        end
        return unflatten(flat)
      end
      return unflatten(parse_xliff(data)) if profile == "xliff" && data.is_a?(String)
      return unflatten(parse_po(data)) if profile == "po" && data.is_a?(String)
      data
    end
    def self.xliff(locale, catalog)
      body = flatten(catalog).keys.sort.collect do |key|
        value = flatten(catalog)[key]
        "      <unit id=\"" + xml_escape(key) + "\"><segment><target xml:lang=\"" + xml_escape(locale) + "\">" + xml_escape(value) + "</target></segment></unit>"
      end.join("\n")
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<xliff version=\"2.1\" srcLang=\"en\" trgLang=\"" + xml_escape(locale) + "\">\n  <file id=\"catalog\">\n" + body + "\n  </file>\n</xliff>\n"
    end

    def self.po(catalog)
      flatten(catalog).keys.sort.collect do |key|
        value = flatten(catalog)[key]
        "msgctxt " + quote(key) + "\nmsgid " + quote(value) + "\nmsgstr " + quote(value) + "\n"
      end.join("\n")
    end

    def self.parse_xliff(source)
      result = {}
      source.scan(/<unit id="([^"]+)">.*?<target[^>]*>(.*?)<\/target>.*?<\/unit>/m) do |key, value|
        result[xml_unescape(key)] = xml_unescape(value)
      end
      result
    end

    def self.parse_po(source)
      result = {}
      source.split(/\n\n+/).each do |entry|
        context = entry[/msgctxt\s+"((?:\\"|[^"])*)"/, 1]
        translated = entry[/msgstr\s+"((?:\\"|[^"])*)"/, 1]
        result[unquote(context)] = unquote(translated) if context && translated
      end
      result
    end

    def self.xml_escape(value)
      value.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("\"", "&quot;")
    end

    def self.xml_unescape(value)
      value.to_s.gsub("&quot;", "\"").gsub("&gt;", ">").gsub("&lt;", "<").gsub("&amp;", "&")
    end

    def self.unquote(value)
      value.to_s.gsub("\\n", "\n").gsub("\\t", "\t").gsub("\\\"", "\"").gsub("\\\\", "\\")
    end
  end
end
