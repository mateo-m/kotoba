require File.join(File.dirname(__FILE__), "registry")

module Kotoba
  module Adapters
    module BareRGSS
      def self.install(options)
        paths = options["catalog_paths"] || options[:catalog_paths]
        if paths
          Kotoba.configure do |config|
            config.catalog_paths = paths
          end
        end
        Kotoba.load! if options["load"] || options[:load]
        install_global_helper if options["install_global"] || options[:install_global]
        true
      end

      def self.translate_message(text, variables)
        if text.to_s[0, 5] == "i18n:"
          return Kotoba.t(text.to_s[5, text.to_s.length - 5], variables || {})
        end
        text
      end

      def self.install_global_helper
        return if Object.method_defined?(:_KOTOBA_MESSAGE) || Object.private_method_defined?(:_KOTOBA_MESSAGE)
        Object.class_eval do
          def _KOTOBA_MESSAGE(text, variables = nil)
            Kotoba::Adapters::BareRGSS.translate_message(text, variables)
          end
        end
      end
    end
  end
end

Kotoba.register_adapter("bare_rgss", Kotoba::Adapters::BareRGSS)
