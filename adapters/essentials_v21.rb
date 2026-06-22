require File.join(File.dirname(__FILE__), "essentials_base")

module Kotoba
  module Adapters
    module EssentialsV21
      def self.install(options)
        paths = options["catalog_paths"] || options[:catalog_paths]
        Kotoba.configure do |config|
          config.catalog_paths = paths if paths
        end
        Kotoba.load! if options["load"] || options[:load]
        true
      end

      def self.load_message_files(fragment, paths)
        Kotoba.configure do |config|
          config.catalog_paths = {fragment.to_s => paths}
        end
        Kotoba.locale = fragment.to_s
      end
    end
  end
end

Kotoba.register_adapter("essentials_v21", Kotoba::Adapters::EssentialsV21)
