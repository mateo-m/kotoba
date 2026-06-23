kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

module KotobaTools
  module CatalogTools
    def self.pseudolocalize_catalog(catalog)
      transform_leaves(catalog) { |message| pseudolocalize_message(message) }
    end

    def self.pseudolocalize_message(message)
      result = "["
      index = 0
      while index < message.length
        char = message[index, 1]
        if char == "{"
          token, index = read_braced(message, index)
          result << token
        elsif char == "\\"
          token = message[index, 2]
          result << token
          index += token.length
        else
          result << pseudo_char(char)
          index += 1
        end
      end
      result << " ~~]"
      result
    end
    def self.read_braced(message, start)
      depth = 0
      index = start
      while index < message.length
        char = message[index, 1]
        depth += 1 if char == "{"
        depth -= 1 if char == "}"
        index += 1
        break if depth == 0
      end
      [message[start, index - start], index]
    end

    def self.pseudo_char(char)
      lower = char.downcase
      return ACCENTS[lower] || char if lower != char
      ACCENTS[char] || char
    end
  end
end
