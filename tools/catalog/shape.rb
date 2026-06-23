kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

module KotobaTools
  module CatalogTools
    def self.flatten(catalog)
      Kotoba::CatalogCompiler.flatten(catalog)
    end

    def self.unflatten(flat)
      result = {}
      flat.each do |key, value|
        cursor = result
        parts = key.to_s.split(".")
        parts.each_with_index do |part, index|
          if index == parts.length - 1
            cursor[part] = value
          else
            cursor[part] = {} unless cursor[part].is_a?(Hash)
            cursor = cursor[part]
          end
        end
      end
      result
    end
    def self.flatten_into(catalog, path, result)
      Kotoba::CatalogCompiler.flatten_into(catalog, path, result)
    end

    def self.transform_leaves(catalog, &block)
      result = {}
      catalog.each do |key, value|
        result[key] = value.is_a?(Hash) ? transform_leaves(value, &block) : yield(value)
      end
      result
    end
    def self.merge_nested_hash(target, source)
      source.each do |key, value|
        if value.is_a?(Hash) && target[key].is_a?(Hash)
          merge_nested_hash(target[key], value)
        else
          target[key] = value
        end
      end
    end
  end
end
