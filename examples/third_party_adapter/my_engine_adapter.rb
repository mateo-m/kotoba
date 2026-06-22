require File.join(File.dirname(__FILE__), "..", "..", "runtime", "rgss_i18n_core")
require File.join(File.dirname(__FILE__), "..", "..", "adapters", "registry")

module RGSSI18n
  module Adapters
    module MyEngine
      def self.install(options)
        paths = options["catalog_paths"] || options[:catalog_paths]
        if paths
          RGSSI18n.configure do |config|
            config.catalog_paths = paths
          end
        end
        RGSSI18n.load! if options["load"] || options[:load]
        true
      end

      def self.translate_text(text, variables)
        if text.to_s[0, 5] == "i18n:"
          return RGSSI18n.t(text.to_s[5, text.to_s.length - 5], variables || {})
        end
        text
      end
    end
  end
end

RGSSI18n.register_adapter("my_engine", RGSSI18n::Adapters::MyEngine)
