require File.join(File.dirname(__FILE__), "essentials_base")

module Kotoba
  module Adapters
    module EssentialsBES
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

      def self.move_name(id)
        EssentialsBase.data_name("moves", id, "name")
      end

      def self.item_name(id)
        EssentialsBase.data_name("items", id, "name")
      end

      def self.ability_name(id)
        EssentialsBase.data_name("abilities", id, "name")
      end
    end
  end
end

Kotoba.register_adapter("essentials_bes", Kotoba::Adapters::EssentialsBES)
