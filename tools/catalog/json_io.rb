kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

module KotobaTools
  module CatalogTools
    def self.load_json(path)
      Kotoba::JSON.parse(File.open(path, "rb") { |file| file.read }, Kotoba::CatalogCompiler::JSON_LOAD_OPTIONS)
    end

    def self.write_json(path, value)
      File.open(path, "wb") do |file|
        file.write(to_json(value, 0))
        file.write("\n")
      end
    end
    def self.to_json(value, depth)
      if value.is_a?(Hash)
        return "{}" if value.empty?
        indent = "  " * depth
        child_indent = "  " * (depth + 1)
        parts = value.keys.sort.collect do |key|
          child_indent + quote(key.to_s) + ": " + to_json(value[key], depth + 1)
        end
        "{\n" + parts.join(",\n") + "\n" + indent + "}"
      elsif value.is_a?(Array)
        "[" + value.collect { |item| to_json(item, depth) }.join(", ") + "]"
      elsif value.is_a?(String)
        quote(value)
      elsif value == true
        "true"
      elsif value == false
        "false"
      elsif value.nil?
        "null"
      else
        value.to_s
      end
    end

    def self.quote(value)
      "\"" + value.gsub(/["\\\n\r\t\x00-\x1f]/) do |char|
        case char
        when "\""
          "\\\""
        when "\\"
          "\\\\"
        when "\n"
          "\\n"
        when "\r"
          "\\r"
        when "\t"
          "\\t"
        else
          "\\u%04x" % char.unpack("C")[0]
        end
      end + "\""
    end
  end
end
