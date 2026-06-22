require File.join(File.dirname(__FILE__), "registry")

module RGSSI18n
  module Adapters
    class BlockedAdapter
      def initialize(name, reason)
        @name = name
        @reason = reason
      end

      def install(options)
        raise AdapterError, @name + " is blocked: " + @reason
      end
    end
  end
end
