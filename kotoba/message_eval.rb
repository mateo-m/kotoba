module Kotoba
  class MessageParseError < StandardError
  end

  class MessageEvaluationError < StandardError
  end

  module MessageEval
    def self.compile(message, options = nil)
      source = message.to_s
      return source if plain_message?(source)
      Parser.new(source, options).parse
    end

    def self.evaluate(compiled, variables, locale, options = nil)
      return compiled if compiled.is_a?(String)
      vars = variables || {}
      evaluate_tokens(compiled, vars, locale, nil, options || {})
    end

    def self.plain_message?(message)
      message.index("{").nil? && message.index("#").nil? && message.index("'").nil?
    end

    def self.evaluate_tokens(tokens, variables, locale, plural_value, options)
      output = ""
      tokens.each do |token|
        kind = token[0]
        if kind == :text
          output << token[1]
        elsif kind == :var
          output << interpolation_value(variables, token[1], options).to_s
        elsif kind == :number
          output << plural_value.to_s
        elsif kind == :select
          branch = token[2][variable_value(variables, token[1]).to_s]
          branch = token[2]["other"] if branch.nil?
          output << evaluate_tokens(branch || [], variables, locale, plural_value, options)
        elsif kind == :plural
          count = integer_variable_value(variables, token[1])
          branch = token[2]["=" + count.to_s]
          branch = token[2][PluralRules.cardinal(locale, count)] if branch.nil?
          branch = token[2]["other"] if branch.nil?
          output << evaluate_tokens(branch || [], variables, locale, count, options)
        end
      end
      output
    end

    def self.variable_value(variables, name)
      return variables[name] if variables.has_key?(name)
      symbol_name = name.to_sym
      return variables[symbol_name] if variables.has_key?(symbol_name)
      "{" + name + "}"
    end

    def self.interpolation_value(variables, name, options)
      if variables.has_key?(name) || variables.has_key?(name.to_sym)
        return variable_value(variables, name)
      end

      policy = options["missing_variable_policy"] || options[:missing_variable_policy] || "keep"
      return "" if policy == "empty"
      if policy == "error"
        raise MessageEvaluationError, "missing variable " + name
      end
      "{" + name + "}"
    end

    def self.integer_variable_value(variables, name)
      unless variables.has_key?(name) || variables.has_key?(name.to_sym)
        raise MessageEvaluationError, "missing plural variable " + name
      end

      value = variable_value(variables, name)
      return value if value.is_a?(Integer)
      if value.is_a?(String) && value =~ /\A-?[0-9]+\z/
        return value.to_i
      end

      raise MessageEvaluationError, "plural variable " + name + " must be an integer"
    end

    class Parser
      def initialize(message, options)
        @message = message
        @index = 0
        @length = @message.length
        @max_depth = option_value(options, "max_depth", 16)
      end

      def parse
        tokens = parse_message(false, false, 0)
        error("unexpected closing brace") if current_char == "}"
        tokens
      end

      private

      def parse_message(stop_on_brace, allow_number, depth)
        error("maximum message depth exceeded") if depth > @max_depth
        tokens = []
        text = ""

        while @index < @length
          char = current_char
          break if stop_on_brace && char == "}"

          if char == "{"
            append_text(tokens, text)
            text = ""
            tokens << parse_argument(allow_number, depth + 1)
          elsif char == "#" && allow_number
            append_text(tokens, text)
            text = ""
            @index += 1
            tokens << [:number]
          elsif char == "'"
            text << parse_apostrophe_text
          else
            text << char
            @index += 1
          end
        end

        append_text(tokens, text)
        tokens
      end

      def parse_argument(allow_number, depth)
        consume("{")
        skip_spaces
        name = read_identifier
        error("missing argument name") if name == ""
        skip_spaces

        if current_char == "}"
          consume("}")
          return [:var, name]
        end

        consume(",")
        skip_spaces
        argument_type = read_identifier
        skip_spaces
        consume(",")

        if argument_type == "select"
          branches = parse_branches(false, depth)
          consume("}")
          require_other_branch(branches, argument_type)
          return [:select, name, branches]
        end

        if argument_type == "plural"
          branches = parse_branches(true, depth)
          consume("}")
          require_other_branch(branches, argument_type)
          return [:plural, name, branches]
        end

        error("unsupported argument type " + argument_type)
      end

      def parse_branches(allow_number, depth)
        branches = {}

        loop do
          skip_spaces
          error("missing argument branches") if @index >= @length
          break if current_char == "}"
          selector = read_selector
          error("missing branch selector") if selector == ""
          skip_spaces
          consume("{")
          branches[selector] = parse_message(true, allow_number, depth)
          consume("}")
        end

        branches
      end

      def require_other_branch(branches, argument_type)
        error(argument_type + " argument must include other branch") unless branches.has_key?("other")
      end

      def parse_apostrophe_text
        if @message[@index + 1, 1] == "'"
          @index += 2
          return "'"
        end

        next_char = @message[@index + 1, 1]
        return consume_literal_apostrophe unless next_char == "{" || next_char == "}" || next_char == "#"

        @index += 1
        text = ""
        while @index < @length
          char = current_char
          if char == "'"
            @index += 1
            return text
          end
          text << char
          @index += 1
        end

        error("unterminated apostrophe escape")
      end

      def consume_literal_apostrophe
        @index += 1
        "'"
      end

      def append_text(tokens, text)
        tokens << [:text, text] unless text == ""
      end

      def option_value(options, key, default_value)
        return default_value if options.nil?
        return options[key] if options.has_key?(key)
        symbol_key = key.to_sym
        return options[symbol_key] if options.has_key?(symbol_key)
        default_value
      end

      def read_identifier
        start = @index
        while @index < @length
          char = current_char
          break unless identifier_char?(char)
          @index += 1
        end
        @message[start, @index - start]
      end

      def read_selector
        start = @index
        while @index < @length
          char = current_char
          break if char == "{" || char == "}" || whitespace?(char)
          @index += 1
        end
        @message[start, @index - start]
      end

      def skip_spaces
        while whitespace?(current_char)
          @index += 1
        end
      end

      def whitespace?(char)
        char == " " || char == "\n" || char == "\r" || char == "\t"
      end

      def identifier_char?(char)
        return false if char.nil?
        return true if char >= "a" && char <= "z"
        return true if char >= "A" && char <= "Z"
        return true if char >= "0" && char <= "9"
        char == "_"
      end

      def consume(expected)
        error("expected " + expected) unless current_char == expected
        @index += 1
      end

      def current_char
        return nil if @index >= @length
        @message[@index, 1]
      end

      def error(message)
        raise MessageParseError, message + " at byte " + @index.to_s
      end
    end
  end
end
