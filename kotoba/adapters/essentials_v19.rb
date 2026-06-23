require File.join(File.dirname(__FILE__), "essentials_base")

module Kotoba
  module Adapters
    module EssentialsV19
      def self.install(options)
        EssentialsBase.install_source_map(options)
        EssentialsBase.install_intl_globals(self, options)
      end

      def self._INTL(source_text, *args)
        EssentialsBase.intl(source_text, args)
      end

      def self._ISPRINTF(source_text, *args)
        EssentialsBase.isprintf(source_text, args)
      end
    end
  end
end

Kotoba.register_adapter("essentials_v19", Kotoba::Adapters::EssentialsV19)
