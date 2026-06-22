require File.join(File.dirname(__FILE__), "essentials_base")

module RGSSI18n
  module Adapters
    module EssentialsV21
      def self.install(options)
        paths = options["catalog_paths"] || options[:catalog_paths]
        RGSSI18n.configure do |config|
          config.catalog_paths = paths if paths
        end
        RGSSI18n.load! if options["load"] || options[:load]
        true
      end

      def self.load_message_files(fragment, paths)
        RGSSI18n.configure do |config|
          config.catalog_paths = {fragment.to_s => paths}
        end
        RGSSI18n.locale = fragment.to_s
      end
    end
  end
end

RGSSI18n.register_adapter("essentials_v21", RGSSI18n::Adapters::EssentialsV21)
