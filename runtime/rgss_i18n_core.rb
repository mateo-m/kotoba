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
      @locale_change_handlers = []
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
      old_locale = @locale
      @locale = normalize_locale(value)
      load_locale_chain(@locale)
      notify_locale_change(old_locale, @locale) unless old_locale == @locale
    end

    def available_locales
      config.available_locales.collect { |value| normalize_locale(value) }
    end

    def on_locale_change(handler = nil, &block)
      @locale_change_handlers = [] if @locale_change_handlers.nil?
      callback = handler || block
      @locale_change_handlers << callback if callback
      callback
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
      paths = (fetch_hash_value(config.catalog_paths, normalized) || []) + discovered_catalog_paths(normalized)
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
      parsed = JSON.parse(source, {
        "max_depth" => config.max_json_depth,
        "duplicate_keys" => config.duplicate_key_policy
      })
      load_hash(locale_value, parsed)
    end

    def load_hash(locale_value, catalog)
      raise CatalogError, "catalog root must be a JSON object" unless catalog.is_a?(Hash)
      normalized = normalize_locale(locale_value)
      @catalogs = {} if @catalogs.nil?
      @catalogs[normalized] = {} unless @catalogs.has_key?(normalized)
      merge_catalog!(@catalogs[normalized], compile_catalog(catalog, []))
      @catalogs[normalized]
    end

    def t(key, variables = nil, options = nil)
      vars = variables || {}
      opts = options || {}
      requested_locale = normalize_locale(fetch_hash_value(opts, "locale") || locale)
      fallback_chain(requested_locale).each do |chain_locale|
        load_locale(chain_locale)
        message = lookup(@catalogs[chain_locale], key)
        return evaluate_message(message, vars, chain_locale) unless message.nil?
      end

      default_message = fetch_hash_value(opts, "default")
      return evaluate_message(MessageEval.compile(default_message, message_options), vars, requested_locale) unless default_message.nil?
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

    def source_text_key(source_text, options = nil)
      opts = options || {}
      requested_locale = normalize_locale(fetch_hash_value(opts, "locale") || locale)
      fallback_chain(requested_locale).each do |chain_locale|
        load_locale(chain_locale)
        catalog = @catalogs[chain_locale]
        source_texts = catalog ? catalog["source_text"] : nil
        if source_texts.is_a?(Hash) && source_texts.has_key?(source_text.to_s)
          return evaluate_message(source_texts[source_text.to_s], {}, chain_locale)
        end
      end
      fetch_hash_value(opts, "default")
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
      if bytes > config.warn_catalog_bytes
        warn_runtime("catalog is large: " + path.to_s + " (" + bytes.to_s + " bytes)")
      end
      @loaded_bytes = 0 if @loaded_bytes.nil?
      @loaded_bytes += bytes
      if @loaded_bytes > config.max_loaded_catalog_bytes
        raise CatalogError, "loaded catalog bytes exceed configured limit"
      end
    end

    def compile_catalog(value, path)
      if value.is_a?(Hash)
        compiled = {}
        value.each do |key, child|
          compiled[key.to_s] = compile_catalog(child, path + [key.to_s])
        end
        return compiled
      end
      return MessageEval.compile(value, message_options) if value.is_a?(String)

      location = path.length == 0 ? "<root>" : path.join(".")
      raise CatalogError, "catalog value must be a string or object at " + location
    end

    def merge_catalog!(target, source)
      source.each do |key, value|
        if target[key].is_a?(Hash) && value.is_a?(Hash)
          merge_catalog!(target[key], value)
        else
          if target.has_key?(key)
            handle_duplicate_key(key)
          end
          target[key] = value
        end
      end
    end

    def evaluate_message(message, variables, locale_value)
      return message if message.is_a?(String)
      MessageEval.evaluate(message, variables, locale_value, message_options)
    end

    def message_options
      {
        "max_depth" => config.max_message_depth,
        "missing_variable_policy" => config.missing_variable_policy
      }
    end

    def handle_duplicate_key(key)
      if config.duplicate_key_policy == "error"
        raise CatalogError, "duplicate catalog key " + key.to_s
      end
      warn_runtime("duplicate catalog key " + key.to_s)
    end

    def warn_runtime(message)
      if config.warning_handler
        config.warning_handler.call(message)
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
      cursor.is_a?(Array) || cursor.is_a?(String) ? cursor : nil
    end

    def discovered_catalog_paths(locale_value)
      paths = []
      (config.catalog_discovery_paths || []).each do |root|
        normalized_root = normalize_path(root)
        direct = File.join(normalized_root, locale_value.to_s + ".json")
        paths << direct if file_exists?(direct)
        Dir[File.join(normalized_root, locale_value.to_s, "*.json")].sort.each do |path|
          paths << path
        end
      end
      paths
    end

    def file_exists?(path)
      File.file?(normalize_path(path))
    end

    def notify_locale_change(old_locale, new_locale)
      if config.locale_change_handler
        config.locale_change_handler.call(old_locale, new_locale)
      end
      (@locale_change_handlers || []).each do |handler|
        handler.call(old_locale, new_locale)
      end
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
