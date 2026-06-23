require File.join(File.dirname(__FILE__), "message_eval")

module Kotoba
  module CatalogCompiler
    JSON_LOAD_OPTIONS = {
      "duplicate_keys" => "error",
      "max_depth" => 64
    }

    def self.ensure_node(value, path, error_class = CatalogError)
      if value.is_a?(Hash)
        value.each do |key, child|
          ensure_node(child, path + [key.to_s], error_class)
        end
        return
      end
      return if value.is_a?(String)

      location = path.length == 0 ? "<root>" : path.join(".")
      raise error_class, "catalog value must be a string or object at " + location
    end

    def self.compile(value, path, message_options = nil)
      if value.is_a?(Hash)
        compiled = {}
        value.each do |key, child|
          compiled[key.to_s] = compile(child, path + [key.to_s], message_options)
        end
        return compiled
      end
      return MessageEval.compile(value, message_options || {}) if value.is_a?(String)

      location = path.length == 0 ? "<root>" : path.join(".")
      raise CatalogError, "catalog value must be a string or object at " + location
    end

    def self.compile_tree(catalog, message_options = nil)
      compile(catalog, [], message_options)
    end

    def self.flatten(catalog)
      result = {}
      flatten_into(catalog, [], result)
      result
    end

    def self.flatten_into(catalog, path, result)
      catalog.each do |key, value|
        current_path = path + [key.to_s]
        if value.is_a?(Hash)
          flatten_into(value, current_path, result)
        else
          result[current_path.join(".")] = value
        end
      end
    end
  end
end
