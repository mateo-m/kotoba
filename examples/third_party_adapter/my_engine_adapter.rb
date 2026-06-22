require File.join(File.dirname(__FILE__), "..", "..", "kotoba", "core")
require File.join(File.dirname(__FILE__), "..", "..", "adapters", "registry")

module Kotoba
  module Adapters
    module MyEngine
      def self.install(options)
        paths = options["catalog_paths"] || options[:catalog_paths]
        if paths
          Kotoba.configure do |config|
            config.catalog_paths = paths
          end
        end
        Kotoba.load! if options["load"] || options[:load]
        true
      end

      def self.translate_text(text, variables)
        if text.to_s[0, 5] == "i18n:"
          return Kotoba.t(text.to_s[5, text.to_s.length - 5], variables || {})
        end
        text
      end
    end
  end
end

Kotoba.register_adapter("my_engine", Kotoba::Adapters::MyEngine)
