require File.join(File.dirname(__FILE__), "registry")

module Kotoba
  module Adapters
    module EssentialsBase
      def self.install_source_map(options)
        catalog_paths = options["catalog_paths"] || options[:catalog_paths]
        Kotoba.configure do |config|
          config.catalog_paths = catalog_paths if catalog_paths
        end
        Kotoba.load! if options["load"] || options[:load]
        true
      end

      def self.install_intl_globals(adapter, options)
        return true unless options["install_global"] || options[:install_global]
        force = options["force_global"] || options[:force_global]
        @global_adapter = adapter
        Object.class_eval do
          if force || !Kotoba::Adapters::EssentialsBase.global_method_defined?(:_INTL)
            def _INTL(*args)
              Kotoba::Adapters::EssentialsBase.global_adapter._INTL(*args)
            end
          end
          if force || !Kotoba::Adapters::EssentialsBase.global_method_defined?(:_ISPRINTF)
            def _ISPRINTF(*args)
              Kotoba::Adapters::EssentialsBase.global_adapter._ISPRINTF(*args)
            end
          end
        end
        true
      end

      def self.global_adapter
        @global_adapter
      end

      def self.global_method_defined?(name)
        Object.method_defined?(name) || Object.private_method_defined?(name)
      end

      def self.intl(source_text, args)
        key = source_key(source_text)
        return positional(source_text, args) if key == ""
        Kotoba.t(key, positional_variables(args))
      end

      def self.isprintf(source_text, args)
        key = source_key(source_text)
        string = key == "" ? source_text.to_s : Kotoba.t(key, positional_variables(args), {"default" => source_text.to_s})
        args.each_with_index do |value, index|
          number = (index + 1).to_s
          string = string.gsub(/\{#{number}\:([^\}]+?)\}/) { |match| sprintf("%" + $1, value) }
          string = string.gsub("{" + number + "}", value.to_s)
        end
        string
      end

      def self.source_key(source_text)
        Kotoba.source_text_key(source_text, {"default" => ""})
      end

      def self.positional_variables(args)
        variables = {}
        args.each_with_index do |value, index|
          variables[positional_name(index)] = value
          variables["arg" + (index + 1).to_s] = value
          variables["value"] = value if index == 0
          variables["count"] = value if index == 0
        end
        variables
      end

      def self.positional(source_text, args)
        result = source_text.to_s.dup
        args.each_with_index do |value, index|
          result = result.gsub("{" + (index + 1).to_s + "}", value.to_s)
        end
        result
      end

      def self.positional_name(index)
        names = ["pokemon", "trainer", "item", "move", "name"]
        names[index] || ("arg" + (index + 1).to_s)
      end

      def self.data_name(namespace, id, field)
        key = "data." + namespace.to_s + "." + id.to_s + "." + field.to_s
        Kotoba.t(key, nil, {"default" => id.to_s})
      end
    end
  end
end
