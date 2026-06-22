require File.join(File.dirname(__FILE__), "essentials_base")

module RGSSI18n
  module Adapters
    module EssentialsBES
      def self.install(options)
        EssentialsBase.install_source_map(options)
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

RGSSI18n.register_adapter("essentials_bes", RGSSI18n::Adapters::EssentialsBES)
