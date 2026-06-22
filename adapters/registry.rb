module RGSSI18n
  class AdapterError < StandardError
  end

  class << self
    def register_adapter(name, adapter)
      @adapters = {} if @adapters.nil?
      @adapters[name.to_s] = adapter
    end

    def adapter(name)
      @adapters ||= {}
      @adapters[name.to_s]
    end

    def available_adapters
      @adapters ||= {}
      @adapters.keys.sort
    end

    def use_adapter(name, options = nil)
      selected = adapter(name)
      raise AdapterError, "unknown adapter " + name.to_s if selected.nil?
      selected.install(options || {})
    end
  end
end
