module KotobaTools
  module CLI
    def self.registry
      @registry ||= {}
    end

    def self.register(name, &handler)
      registry[name] = handler
    end

    def self.registered?(name)
      registry.has_key?(name)
    end

    def self.run(name, argv, context)
      handler = registry[name]
      return nil if handler.nil?
      handler.call(argv, context)
    end
  end
end
