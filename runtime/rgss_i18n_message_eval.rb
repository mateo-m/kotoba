module RGSSI18n
  class MessageParseError < StandardError
  end

  module MessageEval
    def self.compile(message)
      Parser.new(message.to_s).parse
    end

    def self.evaluate(compiled, variables, locale)
      vars = variables || {}
      evaluate_tokens(compiled, vars, locale, nil)
    end

    def self.evaluate_tokens(tokens, variables, locale, plural_value)
      output = ""
      tokens.each do |token|
        kind = token[0]
        if kind == :text
          output << token[1]
        elsif kind == :var
          output << variable_value(variables, token[1]).to_s
        elsif kind == :number
          output << plural_value.to_s
        elsif kind == :select
          branch = token[2][variable_value(variables, token[1]).to_s]
          branch = token[2]["other"] if branch.nil?
          output << evaluate_tokens(branch || [], variables, locale, plural_value)
        elsif kind == :plural
          count = variable_value(variables, token[1]).to_i
          branch = token[2]["=" + count.to_s]
          branch = token[2][PluralRules.cardinal(locale, count)] if branch.nil?
          branch = token[2]["other"] if branch.nil?
          output << evaluate_tokens(branch || [], variables, locale, count)
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

    class Parser
      def initialize(message)
        @message = message
        @index = 0
        @length = @message.length
      end

      def parse
        tokens = parse_message(false, false)
        error("unexpected closing brace") if current_char == "}"
        tokens
      end

      private

      def parse_message(stop_on_brace, allow_number)
        tokens = []
        text = ""

        while @index < @length
          char = current_char
          break if stop_on_brace && char == "}"

          if char == "{"
            append_text(tokens, text)
            text = ""
            tokens << parse_argument(allow_number)
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

      def parse_argument(allow_number)
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
          branches = parse_branches(false)
          consume("}")
          require_other_branch(branches, argument_type)
          return [:select, name, branches]
        end

        if argument_type == "plural"
          branches = parse_branches(true)
          consume("}")
          require_other_branch(branches, argument_type)
          return [:plural, name, branches]
        end

        error("unsupported argument type " + argument_type)
      end

      def parse_branches(allow_number)
        branches = {}

        loop do
          skip_spaces
          error("missing argument branches") if @index >= @length
          break if current_char == "}"
          selector = read_selector
          error("missing branch selector") if selector == ""
          skip_spaces
          consume("{")
          branches[selector] = parse_message(true, allow_number)
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
