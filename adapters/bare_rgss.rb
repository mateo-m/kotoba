require File.join(File.dirname(__FILE__), "registry")

module RGSSI18n
  module Adapters
    module BareRGSS
      def self.install(options)
        paths = options["catalog_paths"] || options[:catalog_paths]
        if paths
          RGSSI18n.configure do |config|
            config.catalog_paths = paths
          end
        end
        RGSSI18n.load! if options["load"] || options[:load]
        install_global_helper if options["install_global"] || options[:install_global]
        true
      end

      def self.translate_message(text, variables)
        if text.to_s[0, 5] == "i18n:"
          return RGSSI18n.t(text.to_s[5, text.to_s.length - 5], variables || {})
        end
        text
      end

      def self.install_global_helper
        return if Object.method_defined?(:_RGSSI18N_MESSAGE) || Object.private_method_defined?(:_RGSSI18N_MESSAGE)
        Object.class_eval do
          def _RGSSI18N_MESSAGE(text, variables = nil)
            RGSSI18n::Adapters::BareRGSS.translate_message(text, variables)
          end
        end
      end
    end
  end
end

RGSSI18n.register_adapter("bare_rgss", RGSSI18n::Adapters::BareRGSS)
