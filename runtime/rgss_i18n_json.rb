module RGSSI18n
  class JSONParseError < StandardError
  end

  module JSON
    def self.parse(source, options = nil)
      Parser.new(source, options).parse
    end

    class Parser
      def initialize(source, options)
        @source = source.to_s
        strip_bom!
        @index = 0
        @length = @source.length
        @max_depth = option_value(options, "max_depth", 64)
        @duplicate_key_policy = option_value(options, "duplicate_keys", "override")
      end

      def parse
        skip_whitespace
        value = parse_value(0)
        skip_whitespace
        error("unexpected trailing content") if @index < @length
        value
      end

      private

      def strip_bom!
        bytes = @source.unpack("C*")
        if bytes[0, 3] == [0xEF, 0xBB, 0xBF]
          @source = bytes[3, bytes.length - 3].pack("C*")
        end
      end

      def option_value(options, key, default_value)
        return default_value if options.nil?
        return options[key] if options.has_key?(key)
        symbol_key = key.to_sym
        return options[symbol_key] if options.has_key?(symbol_key)
        default_value
      end

      def parse_value(depth)
        error("maximum JSON depth exceeded") if depth > @max_depth
        skip_whitespace
        error("unexpected end of input") if @index >= @length

        char = current_char
        return parse_object(depth + 1) if char == "{"
        return parse_array(depth + 1) if char == "["
        return parse_string if char == "\""
        return parse_number if char == "-" || digit?(char)
        return parse_literal("true", true) if starts_with?("true")
        return parse_literal("false", false) if starts_with?("false")
        return parse_literal("null", nil) if starts_with?("null")

        error("unexpected token")
      end

      def parse_object(depth)
        result = {}
        consume("{")
        skip_whitespace
        if current_char == "}"
          consume("}")
          return result
        end

        loop do
          skip_whitespace
          error("object keys must be strings") unless current_char == "\""
          key = parse_string
          if result.has_key?(key) && @duplicate_key_policy == "error"
            error("duplicate object key " + key)
          end
          skip_whitespace
          consume(":")
          result[key] = parse_value(depth)
          skip_whitespace
          char = current_char
          if char == "}"
            consume("}")
            break
          end
          consume(",")
        end

        result
      end

      def parse_array(depth)
        result = []
        consume("[")
        skip_whitespace
        if current_char == "]"
          consume("]")
          return result
        end

        loop do
          result << parse_value(depth)
          skip_whitespace
          char = current_char
          if char == "]"
            consume("]")
            break
          end
          consume(",")
        end

        result
      end

      def parse_string
        result = ""
        consume("\"")

        while @index < @length
          char = current_char
          byte = char.unpack("C")[0]
          error("unescaped control character in string") if !byte.nil? && byte < 32

          if char == "\""
            consume("\"")
            return result
          end

          if char == "\\"
            @index += 1
            result << parse_escape
          else
            result << char
            @index += 1
          end
        end

        error("unterminated string")
      end

      def parse_escape
        error("unterminated escape") if @index >= @length
        char = current_char
        @index += 1

        return "\"" if char == "\""
        return "\\" if char == "\\"
        return "/" if char == "/"
        return "\b" if char == "b"
        return "\f" if char == "f"
        return "\n" if char == "n"
        return "\r" if char == "r"
        return "\t" if char == "t"
        return parse_unicode_escape if char == "u"

        error("invalid escape sequence")
      end

      def parse_unicode_escape
        codepoint = read_hex_codepoint
        if high_surrogate?(codepoint)
          if @source[@index, 2] == "\\u"
            @index += 2
            low = read_hex_codepoint
            error("invalid unicode surrogate pair") unless low_surrogate?(low)
            codepoint = 0x10000 + ((codepoint - 0xD800) * 0x400) + (low - 0xDC00)
          else
            error("missing unicode low surrogate")
          end
        elsif low_surrogate?(codepoint)
          error("unexpected unicode low surrogate")
        end

        utf8(codepoint)
      end

      def read_hex_codepoint
        error("incomplete unicode escape") if @index + 4 > @length
        hex = @source[@index, 4]
        error("invalid unicode escape") unless hex =~ /\A[0-9a-fA-F]{4}\z/
        @index += 4
        hex.to_i(16)
      end

      def parse_number
        start = @index
        consume("-") if current_char == "-"

        if current_char == "0"
          @index += 1
          error("invalid number") if digit?(current_char)
        else
          error("invalid number") unless digit_one_to_nine?(current_char)
          @index += 1
          @index += 1 while digit?(current_char)
        end

        if current_char == "."
          @index += 1
          error("invalid number fraction") unless digit?(current_char)
          @index += 1 while digit?(current_char)
        end

        if current_char == "e" || current_char == "E"
          @index += 1
          @index += 1 if current_char == "+" || current_char == "-"
          error("invalid number exponent") unless digit?(current_char)
          @index += 1 while digit?(current_char)
        end

        number = @source[start, @index - start]
        if number.index(".") || number.index("e") || number.index("E")
          number.to_f
        else
          number.to_i
        end
      end

      def parse_literal(text, value)
        @index += text.length
        value
      end

      def skip_whitespace
        while @index < @length
          char = current_char
          break unless char == " " || char == "\n" || char == "\r" || char == "\t"
          @index += 1
        end
      end

      def consume(expected)
        error("expected " + expected) unless current_char == expected
        @index += 1
      end

      def current_char
        return nil if @index >= @length
        @source[@index, 1]
      end

      def starts_with?(text)
        @source[@index, text.length] == text
      end

      def digit?(char)
        !char.nil? && char >= "0" && char <= "9"
      end

      def digit_one_to_nine?(char)
        !char.nil? && char >= "1" && char <= "9"
      end

      def high_surrogate?(codepoint)
        codepoint >= 0xD800 && codepoint <= 0xDBFF
      end

      def low_surrogate?(codepoint)
        codepoint >= 0xDC00 && codepoint <= 0xDFFF
      end

      def utf8(codepoint)
        error("invalid unicode codepoint") if codepoint < 0 || codepoint > 0x10FFFF
        return [codepoint].pack("C") if codepoint <= 0x7F
        if codepoint <= 0x7FF
          return [
            0xC0 | (codepoint >> 6),
            0x80 | (codepoint & 0x3F)
          ].pack("C*")
        end
        if codepoint <= 0xFFFF
          return [
            0xE0 | (codepoint >> 12),
            0x80 | ((codepoint >> 6) & 0x3F),
            0x80 | (codepoint & 0x3F)
          ].pack("C*")
        end
        [
          0xF0 | (codepoint >> 18),
          0x80 | ((codepoint >> 12) & 0x3F),
          0x80 | ((codepoint >> 6) & 0x3F),
          0x80 | (codepoint & 0x3F)
        ].pack("C*")
      end

      def error(message)
        raise JSONParseError, message + " at byte " + @index.to_s
      end
    end
  end
end
