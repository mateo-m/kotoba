require File.join(File.dirname(__FILE__), "rgss_i18n_config")
require File.join(File.dirname(__FILE__), "rgss_i18n_json")
require File.join(File.dirname(__FILE__), "rgss_i18n_plural_rules")
require File.join(File.dirname(__FILE__), "rgss_i18n_message_eval")

module RGSSI18n
  class MissingTranslationError < StandardError
  end

  class CatalogError < StandardError
  end

  class << self
    def reset!
      @config = Config.new
      @locale = normalize_locale(@config.default_locale)
      @catalogs = {}
      @loaded_bytes = 0
      install_global_helpers!
    end

    def config
      reset! if @config.nil?
      @config
    end

    def configure
      yield config
      @locale = normalize_locale(config.default_locale) if @locale.nil?
      install_global_helpers!
      config
    end

    def locale
      reset! if @locale.nil?
      @locale
    end

    def locale=(value)
      @locale = normalize_locale(value)
      load_locale_chain(@locale)
    end

    def available_locales
      config.available_locales.collect { |value| normalize_locale(value) }
    end

    def fallback_chain(locale_value)
      normalized = normalize_locale(locale_value || locale)
      configured = fetch_hash_value(config.fallbacks, normalized)
      chain = configured ? configured.collect { |value| normalize_locale(value) } : automatic_fallback_chain(normalized)
      result = [normalized]
      chain.each do |fallback_locale|
        result << fallback_locale unless result.include?(fallback_locale)
      end
      default_locale = normalize_locale(config.default_locale)
      result << default_locale unless result.include?(default_locale)
      result
    end

    def load!
      load_locale_chain(locale)
    end

    def reload!
      @catalogs = {}
      @loaded_bytes = 0
      load!
    end

    def load_locale_chain(locale_value)
      fallback_chain(locale_value).each do |chain_locale|
        load_locale(chain_locale)
      end
    end

    def load_locale(locale_value)
      normalized = normalize_locale(locale_value)
      return @catalogs[normalized] if @catalogs && @catalogs.has_key?(normalized)

      @catalogs = {} if @catalogs.nil?
      @catalogs[normalized] = {}
      paths = fetch_hash_value(config.catalog_paths, normalized) || []
      paths.each do |path|
        load_path(normalized, path)
      end
      @catalogs[normalized]
    end

    def load_path(locale_value, path)
      source = read_catalog_file(path)
      check_catalog_size(path, source.length)
      load_json(locale_value, source)
    end

    def load_json(locale_value, source)
      parsed = JSON.parse(source, {"max_depth" => config.max_json_depth})
      load_hash(locale_value, parsed)
    end

    def load_hash(locale_value, catalog)
      raise CatalogError, "catalog root must be a JSON object" unless catalog.is_a?(Hash)
      normalized = normalize_locale(locale_value)
      @catalogs = {} if @catalogs.nil?
      @catalogs[normalized] = {} unless @catalogs.has_key?(normalized)
      merge_catalog!(@catalogs[normalized], compile_catalog(catalog))
      @catalogs[normalized]
    end

    def t(key, variables = nil, options = nil)
      vars = variables || {}
      opts = options || {}
      requested_locale = normalize_locale(fetch_hash_value(opts, "locale") || locale)
      fallback_chain(requested_locale).each do |chain_locale|
        load_locale(chain_locale)
        message = lookup(@catalogs[chain_locale], key)
        return MessageEval.evaluate(message, vars, chain_locale) unless message.nil?
      end

      default_message = fetch_hash_value(opts, "default")
      return MessageEval.evaluate(MessageEval.compile(default_message), vars, requested_locale) unless default_message.nil?
      missing_translation(key, requested_locale)
    end

    def namespace(prefix)
      lambda do |*args|
        key = args[0]
        variables = args[1]
        options = args[2]
        t(prefix.to_s + "." + key.to_s, variables, options)
      end
    end

    def normalize_locale(value)
      parts = value.to_s.gsub("_", "-").split("-")
      return "" if parts.length == 0
      normalized = []
      parts.each_with_index do |part, index|
        if index == 0
          normalized << part.downcase
        elsif part.length == 2
          normalized << part.upcase
        else
          normalized << part
        end
      end
      normalized.join("-")
    end

    def install_global_helpers!
      if config.global_helper && !object_has_method?(:_T)
        Object.class_eval do
          def _T(key, variables = nil, options = nil)
            RGSSI18n.t(key, variables, options)
          end
        end
      end

      if config.i18n_alias && !Object.const_defined?(:I18n)
        Object.const_set(:I18n, RGSSI18n)
      end
    end

    private

    def object_has_method?(name)
      Object.method_defined?(name) || Object.private_method_defined?(name)
    end

    def automatic_fallback_chain(locale_value)
      parts = locale_value.to_s.split("-")
      chain = []
      if parts.length > 1
        language = parts[0]
        chain << language unless language == locale_value
      end
      configured_default = fetch_hash_value(config.fallbacks, "default") || []
      configured_default.each do |fallback_locale|
        normalized = normalize_locale(fallback_locale)
        chain << normalized unless chain.include?(normalized)
      end
      chain
    end

    def fetch_hash_value(hash, key)
      return nil if hash.nil?
      return hash[key] if hash.has_key?(key)
      symbol_key = key.to_sym
      return hash[symbol_key] if hash.has_key?(symbol_key)
      nil
    end

    def read_catalog_file(path)
      if config.file_loader
        return config.file_loader.call(path)
      end

      file = File.open(normalize_path(path), "rb")
      begin
        file.read
      ensure
        file.close
      end
    end

    def normalize_path(path)
      path.to_s.gsub("\\", "/")
    end

    def check_catalog_size(path, bytes)
      if bytes > config.max_catalog_bytes
        raise CatalogError, "catalog is too large: " + path.to_s
      end
      @loaded_bytes = 0 if @loaded_bytes.nil?
      @loaded_bytes += bytes
      if @loaded_bytes > config.max_loaded_catalog_bytes
        raise CatalogError, "loaded catalog bytes exceed configured limit"
      end
    end

    def compile_catalog(value)
      if value.is_a?(Hash)
        compiled = {}
        value.each do |key, child|
          compiled[key.to_s] = compile_catalog(child)
        end
        return compiled
      end
      return MessageEval.compile(value) if value.is_a?(String)
      value
    end

    def merge_catalog!(target, source)
      source.each do |key, value|
        if target[key].is_a?(Hash) && value.is_a?(Hash)
          merge_catalog!(target[key], value)
        else
          target[key] = value
        end
      end
    end

    def lookup(catalog, key)
      return nil if catalog.nil?
      cursor = catalog
      key.to_s.split(".").each do |part|
        return nil unless cursor.is_a?(Hash)
        return nil unless cursor.has_key?(part)
        cursor = cursor[part]
      end
      cursor.is_a?(Array) ? cursor : nil
    end

    def missing_translation(key, locale_value)
      if config.missing_handler
        return config.missing_handler.call(key, locale_value)
      end

      log_missing(key, locale_value) if config.diagnostics
      if config.strict
        raise MissingTranslationError, "missing translation " + key.to_s + " for " + locale_value.to_s
      end
      return "translation missing: " + key.to_s if config.show_missing_keys
      key.to_s
    end

    def log_missing(key, locale_value)
      file = File.open(config.diagnostics_file, "ab")
      begin
        file.write(locale_value.to_s + " " + key.to_s + "\n")
      ensure
        file.close
      end
    end
  end
end

RGSSI18n.reset!
