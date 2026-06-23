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
      parsed = Kotoba::JSON.parse(source, Kotoba::CatalogCompiler::JSON_LOAD_OPTIONS)
      Kotoba::CatalogCompiler.ensure_node(parsed, [], ValidationError)
      parsed
    end

    def load_test(paths)
      paths.each do |path|
        catalog = load_catalog(path)
        Kotoba::CatalogCompiler.compile_tree(catalog)
      end
      true
    rescue Kotoba::JSONParseError, Kotoba::CatalogError, Kotoba::MessageParseError => error
      @errors << error.message
      false
    end

    def schema(schema_name, path)
      data = load_json(path)
      if schema_name == "catalog"
        Kotoba::CatalogCompiler.ensure_node(data, [], ValidationError)
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

    def validate(source_path, locale_paths, human = false)
      source = load_catalog(source_path)
      source_messages = Kotoba::CatalogCompiler.flatten(source)
      Kotoba::CatalogCompiler.compile_tree(source)
      ok = true

      locale_paths.each do |path|
        locale = load_catalog(path)
        Kotoba::CatalogCompiler.compile_tree(locale)
        messages = Kotoba::CatalogCompiler.flatten(locale)
        ok = false unless validate_locale(path, source_messages, messages, human)
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
      Kotoba::JSON.parse(File.open(path, "rb") { |file| file.read }, Kotoba::CatalogCompiler::JSON_LOAD_OPTIONS)
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

    def validate_locale(path, source_messages, messages, human)
      ok = true
      source_messages.each do |key, source_message|
        unless messages.has_key?(key)
          if human
            @errors << human_missing_key(path, key, source_message)
          else
            @errors << path + ": missing key " + key
          end
          ok = false
          next
        end

        target_message = messages[key]
        if placeholders(source_message) != placeholders(target_message)
          if human
            @errors << human_placeholder_mismatch(path, key, source_message, target_message)
          else
            @errors << path + ": placeholder mismatch " + key
          end
          ok = false
        end
        if control_codes(source_message) != control_codes(target_message)
          if human
            @errors << human_control_code_mismatch(path, key, source_message, target_message)
          else
            @errors << path + ": control-code mismatch " + key
          end
          ok = false
        end
      end
      ok
    end

    def human_missing_key(path, key, source_message)
      "In " + File.basename(path) + ": this line still needs a translation (key: " + key + "). English: \"" + truncate_for_human(source_message) + "\""
    end

    def human_placeholder_mismatch(path, key, source_message, target_message)
      expected = placeholders(source_message)
      actual = placeholders(target_message)
      missing = expected - actual
      extra = actual - expected
      parts = ["In " + File.basename(path) + ": keep the same {placeholders} as English for \"" + truncate_for_human(source_message) + "\" (key: " + key + ")."]
      parts << "Missing: " + format_placeholder_list(missing) + "." unless missing.empty?
      parts << "Unexpected: " + format_placeholder_list(extra) + "." unless extra.empty?
      parts.join(" ")
    end

    def human_control_code_mismatch(path, key, source_message, _target_message)
      codes = control_codes(source_message)
      "In " + File.basename(path) + ": copy the RPG Maker color codes from English for \"" + truncate_for_human(source_message) + "\" (key: " + key + "). Expected codes: " + codes.join(", ")
    end

    def truncate_for_human(message)
      text = message.to_s
      return text if text.length <= 80
      text[0, 77] + "..."
    end

    def format_placeholder_list(values)
      values.collect { |value| "{" + value + "}" }.join(", ")
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
