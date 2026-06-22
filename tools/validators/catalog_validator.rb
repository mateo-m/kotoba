kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"

module KotobaTools
  class ValidationError < StandardError
  end

  class CatalogValidator
    attr_reader :errors

    def initialize
      @errors = []
    end

    def load_catalog(path)
      source = File.open(path, "rb") { |file| file.read }
      parsed = Kotoba::JSON.parse(source, {
        "duplicate_keys" => "error",
        "max_depth" => 64
      })
      ensure_catalog_node(parsed, [])
      parsed
    end

    def load_test(paths)
      paths.each do |path|
        catalog = load_catalog(path)
        compile_messages(catalog, [])
      end
      true
    rescue Kotoba::JSONParseError, Kotoba::CatalogError, Kotoba::MessageParseError => error
      @errors << error.message
      false
    end

    def schema(schema_name, path)
      data = load_json(path)
      if schema_name == "catalog"
        ensure_catalog_node(data, [])
      elsif schema_name == "metadata"
        ensure_metadata(data)
      elsif schema_name == "validation"
        ensure_validation_config(data)
      else
        raise ValidationError, "unknown schema " + schema_name.to_s
      end
      true
    rescue Kotoba::JSONParseError, ValidationError => error
      @errors << error.message
      false
    end

    def validate(source_path, locale_paths)
      source = load_catalog(source_path)
      source_messages = flatten_catalog(source)
      compile_messages(source, [])
      ok = true

      locale_paths.each do |path|
        locale = load_catalog(path)
        compile_messages(locale, [])
        messages = flatten_catalog(locale)
        ok = false unless validate_locale(path, source_messages, messages)
      end

      ok
    rescue Kotoba::JSONParseError, ValidationError, Kotoba::MessageParseError => error
      @errors << error.message
      false
    end

    def report
      grouped = {}
      @errors.each do |message|
        type = error_type(message)
        grouped[type] = 0 unless grouped.has_key?(type)
        grouped[type] += 1
      end
      {
        "ok" => @errors.empty?,
        "error_count" => @errors.length,
        "groups" => grouped,
        "errors" => @errors
      }
    end

    private

    def error_type(message)
      return "missing_key" if message.index("missing key")
      return "placeholder_mismatch" if message.index("placeholder mismatch")
      return "control_code_mismatch" if message.index("control-code mismatch")
      return "schema" if message.index("schema")
      "error"
    end

    def load_json(path)
      Kotoba::JSON.parse(File.open(path, "rb") { |file| file.read }, {
        "duplicate_keys" => "error",
        "max_depth" => 64
      })
    end

    def ensure_catalog_node(value, path)
      if value.is_a?(Hash)
        value.each do |key, child|
          ensure_catalog_node(child, path + [key.to_s])
        end
        return
      end
      return if value.is_a?(String)

      location = path.length == 0 ? "<root>" : path.join(".")
      raise ValidationError, "catalog value must be a string or object at " + location
    end

    def ensure_metadata(value)
      raise ValidationError, "metadata root must be an object" unless value.is_a?(Hash)
      value.each do |key, metadata|
        raise ValidationError, "metadata for " + key.to_s + " must be an object" unless metadata.is_a?(Hash)
        metadata.each do |field, field_value|
          unless ["description", "speaker", "context", "max_length", "source"].include?(field.to_s)
            raise ValidationError, "unknown metadata field " + field.to_s
          end
          if field.to_s == "max_length"
            raise ValidationError, "max_length must be a positive integer" unless field_value.is_a?(Integer) && field_value > 0
          else
            raise ValidationError, field.to_s + " must be a string" unless field_value.is_a?(String)
          end
        end
      end
    end

    def ensure_validation_config(value)
      raise ValidationError, "validation config root must be an object" unless value.is_a?(Hash)
      value.each do |key, field_value|
        name = key.to_s
        unless ["source_locale", "locales", "fallbacks", "control_codes"].include?(name)
          raise ValidationError, "unknown validation field " + name
        end
        if name == "source_locale"
          raise ValidationError, "source_locale must be a string" unless field_value.is_a?(String)
        elsif name == "locales"
          raise ValidationError, "locales must be an array" unless field_value.is_a?(Array)
        elsif name == "fallbacks"
          raise ValidationError, "fallbacks must be an object" unless field_value.is_a?(Hash)
        elsif name == "control_codes"
          unless ["ignore", "warn", "error"].include?(field_value)
            raise ValidationError, "control_codes must be ignore, warn, or error"
          end
        end
      end
    end

    def compile_messages(catalog, path)
      catalog.each do |key, value|
        current_path = path + [key.to_s]
        if value.is_a?(Hash)
          compile_messages(value, current_path)
        else
          Kotoba::MessageEval.compile(value)
        end
      end
    end

    def flatten_catalog(catalog)
      result = {}
      flatten_catalog_into(catalog, [], result)
      result
    end

    def flatten_catalog_into(catalog, path, result)
      catalog.each do |key, value|
        current_path = path + [key.to_s]
        if value.is_a?(Hash)
          flatten_catalog_into(value, current_path, result)
        else
          result[current_path.join(".")] = value
        end
      end
    end

    def validate_locale(path, source_messages, messages)
      ok = true
      source_messages.each do |key, source_message|
        unless messages.has_key?(key)
          @errors << path + ": missing key " + key
          ok = false
          next
        end

        target_message = messages[key]
        if placeholders(source_message) != placeholders(target_message)
          @errors << path + ": placeholder mismatch " + key
          ok = false
        end
        if control_codes(source_message) != control_codes(target_message)
          @errors << path + ": control-code mismatch " + key
          ok = false
        end
      end
      ok
    end

    def placeholders(message)
      tokens = Kotoba::MessageEval.compile(message)
      return [] if tokens.is_a?(String)
      vars = []
      collect_placeholders(tokens, vars)
      vars.uniq.sort
    end

    def collect_placeholders(tokens, vars)
      tokens.each do |token|
        if token[0] == :var || token[0] == :select || token[0] == :plural
          vars << token[1]
        end
        if token[0] == :select || token[0] == :plural
          token[2].each do |selector, branch|
            collect_placeholders(branch, vars)
          end
        end
      end
    end

    def control_codes(message)
      message.scan(/\\[A-Za-z!\.\^\>\<\|](?:\[[^\]]+\])?/).sort
    end
  end
end
