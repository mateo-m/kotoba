runtime_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "runtime"))
$LOAD_PATH.unshift(runtime_path) unless $LOAD_PATH.include?(runtime_path)

require "rgss_i18n_core"
require "fileutils"

class OrderedHash < Hash
  def initialize
    @keys = []
    super
  end

  def keys
    @keys.clone
  end

  def []=(key, value)
    oldvalue = self[key]
    if !oldvalue && value
      @keys.push(key)
    elsif !value
      @keys |= []
      @keys -= [key]
    end
    super(key, value)
  end

  def self._load(string)
    result = new
    keysvalues = Marshal.load(string)
    keys = keysvalues[0]
    values = keysvalues[1]
    for index in 0...keys.length
      result[keys[index]] = values[index]
    end
    result
  end

  def _dump(_depth = 100)
    values = []
    keys.each do |key|
      values << self[key]
    end
    Marshal.dump([keys, values])
  end
end

module RGSSI18nTools
  module CatalogTools
    ACCENTS = {
      "a" => "a", "b" => "b", "c" => "c", "d" => "d", "e" => "e",
      "f" => "f", "g" => "g", "h" => "h", "i" => "i", "j" => "j",
      "k" => "k", "l" => "l", "m" => "m", "n" => "n", "o" => "o",
      "p" => "p", "q" => "q", "r" => "r", "s" => "s", "t" => "t",
      "u" => "u", "v" => "v", "w" => "w", "x" => "x", "y" => "y",
      "z" => "z"
    }
    MESSAGE_SECTION_NAMES = [
      "maps",
      "species",
      "kinds",
      "entries",
      "form_names",
      "moves",
      "move_descriptions",
      "items",
      "item_plurals",
      "item_descriptions",
      "abilities",
      "ability_descriptions",
      "types",
      "trainer_types",
      "trainer_names",
      "begin_speech",
      "end_speech_win",
      "end_speech_lose",
      "region_names",
      "place_names",
      "place_descriptions",
      "map_names",
      "phone_messages",
      "script_texts"
    ]
    MESSAGE_SECTION_NAMES_V18 = MESSAGE_SECTION_NAMES[0, 23] + ["trainer_lose_text", "script_texts"]

    def self.load_json(path)
      RGSSI18n::JSON.parse(File.open(path, "rb") { |file| file.read }, {
        "duplicate_keys" => "error",
        "max_depth" => 64
      })
    end

    def self.write_json(path, value)
      File.open(path, "wb") do |file|
        file.write(to_json(value, 0))
        file.write("\n")
      end
    end

    def self.flatten(catalog)
      result = {}
      flatten_into(catalog, [], result)
      result
    end

    def self.unflatten(flat)
      result = {}
      flat.each do |key, value|
        cursor = result
        parts = key.to_s.split(".")
        parts.each_with_index do |part, index|
          if index == parts.length - 1
            cursor[part] = value
          else
            cursor[part] = {} unless cursor[part].is_a?(Hash)
            cursor = cursor[part]
          end
        end
      end
      result
    end

    def self.pseudolocalize_catalog(catalog)
      transform_leaves(catalog) { |message| pseudolocalize_message(message) }
    end

    def self.pseudolocalize_message(message)
      result = "["
      index = 0
      while index < message.length
        char = message[index, 1]
        if char == "{"
          token, index = read_braced(message, index)
          result << token
        elsif char == "\\"
          token = message[index, 2]
          result << token
          index += token.length
        else
          result << pseudo_char(char)
          index += 1
        end
      end
      result << " ~~]"
      result
    end

    def self.export_profile(profile, locale, catalog)
      if profile == "flat_dot_keys"
        return flatten(catalog)
      end
      if profile == "simplelocalize_multi_language_json"
        result = {}
        flatten(catalog).each do |key, value|
          result[key] = {locale => value}
        end
        return result
      end
      return xliff(locale, catalog) if profile == "xliff"
      return po(catalog) if profile == "po"
      catalog
    end

    def self.import_profile(profile, locale, data)
      if profile == "flat_dot_keys"
        return unflatten(data)
      end
      if profile == "simplelocalize_multi_language_json"
        flat = {}
        data.each do |key, value|
          flat[key] = value[locale] if value.is_a?(Hash) && value.has_key?(locale)
        end
        return unflatten(flat)
      end
      return unflatten(parse_xliff(data)) if profile == "xliff" && data.is_a?(String)
      return unflatten(parse_po(data)) if profile == "po" && data.is_a?(String)
      data
    end

    def self.extract_pbs(namespace, path)
      entries = {}
      File.open(path, "rb") do |file|
        file.each_line do |line|
          row = line.strip
          next if row == "" || row[0, 1] == "#" || row[0, 1] == "["
          fields = split_csv_line(row)
          next if fields.length < 2
          id = normalize_identifier(fields[1] || fields[0])
          entries[id] = pbs_entry(fields)
        end
      end
      {"data" => {namespace.to_s => entries}}
    end

    def self.import_essentials_pairs(path, namespace)
      source_text = {}
      flat = {}
      index = 1
      pending = nil
      File.open(path, "rb") do |file|
        file.each_line do |line|
          text = line.chomp
          next if text == "" || text[0, 1] == "#"
          if pending.nil?
            pending = text
          else
            key = namespace.to_s + ".line_" + zero_pad(index, 4)
            source_text[pending] = key
            flat[key] = text == "" ? pending : text
            index += 1
            pending = nil
          end
        end
      end
      result = unflatten(flat)
      result["source_text"] = source_text
      result
    end

    def self.load_messages_dat(path)
      Marshal.load(File.open(path, "rb") { |file| file.read })
    end

    def self.extract_messages_dat(path)
      data = load_messages_dat(path)
      result = {
        "format" => "pokemon_essentials_messages_dat",
        "section_count" => data.length,
        "sections" => {}
      }
      data.each_with_index do |section, index|
        next if section.nil?
        name = messages_dat_section_name(index, data.length)
        result["sections"][name] = extract_messages_dat_section(section, index, data.length)
      end
      result
    end

    def self.migrate_messages_dat(path, namespace)
      data = load_messages_dat(path)
      flat = {}
      source_text = {}
      data.each_with_index do |section, index|
        next if section.nil?
        name = messages_dat_section_name(index, data.length)
        migrate_messages_dat_section(section, namespace.to_s, name, flat, source_text)
      end
      result = unflatten(flat)
      result["source_text"] = source_text unless source_text.empty?
      result
    end

    def self.write_handoff_package(output_dir, locale, source_path, metadata_path)
      catalog = load_json(source_path)
      FileUtils.mkdir_p(output_dir)
      write_json(File.join(output_dir, "source." + locale.to_s + ".json"), catalog)
      write_json(File.join(output_dir, "flat." + locale.to_s + ".json"), flatten(catalog))
      write_json(File.join(output_dir, "pseudo." + locale.to_s + ".json"), pseudolocalize_catalog(catalog))
      if metadata_path && File.file?(metadata_path)
        FileUtils.cp(metadata_path, File.join(output_dir, "metadata.json"))
      end
      File.open(File.join(output_dir, "README.md"), "wb") do |file|
        file.write("# Translation Handoff\n\n")
        file.write("- Source locale: `" + locale.to_s + "`\n")
        file.write("- `source." + locale.to_s + ".json`: runtime catalog\n")
        file.write("- `flat." + locale.to_s + ".json`: flat dot-key catalog\n")
        file.write("- `pseudo." + locale.to_s + ".json`: pseudolocalized QA catalog\n\n")
        file.write("Do not remove placeholders like `{name}` or RPG Maker control codes like `\\\\c[2]`.\n")
      end
      true
    end

    def self.to_json(value, depth)
      if value.is_a?(Hash)
        return "{}" if value.empty?
        indent = "  " * depth
        child_indent = "  " * (depth + 1)
        parts = value.keys.sort.collect do |key|
          child_indent + quote(key.to_s) + ": " + to_json(value[key], depth + 1)
        end
        "{\n" + parts.join(",\n") + "\n" + indent + "}"
      elsif value.is_a?(Array)
        "[" + value.collect { |item| to_json(item, depth) }.join(", ") + "]"
      elsif value.is_a?(String)
        quote(value)
      elsif value == true
        "true"
      elsif value == false
        "false"
      elsif value.nil?
        "null"
      else
        value.to_s
      end
    end

    def self.quote(value)
      "\"" + value.gsub(/["\\\n\r\t\x00-\x1f]/) do |char|
        case char
        when "\""
          "\\\""
        when "\\"
          "\\\\"
        when "\n"
          "\\n"
        when "\r"
          "\\r"
        when "\t"
          "\\t"
        else
          "\\u%04x" % char.unpack("C")[0]
        end
      end + "\""
    end

    def self.messages_dat_section_name(index, total)
      names = total >= 25 ? MESSAGE_SECTION_NAMES_V18 : MESSAGE_SECTION_NAMES
      names[index] || ("section_" + zero_pad(index, 2))
    end

    def self.extract_messages_dat_section(section, index, total)
      if index == 0 && section.is_a?(Array)
        maps = {}
        section.each_with_index do |messages, map_index|
          next if messages.nil?
          maps["map_" + zero_pad(map_index, 4)] = extract_messages_dat_entries(messages)
        end
        return {"type" => "maps", "maps" => maps}
      end

      if section.is_a?(Array)
        entries = {}
        section.each_with_index do |value, entry_index|
          next if value.nil? || value == ""
          entries["id_" + zero_pad(entry_index, 4)] = value
        end
        return {"type" => "array", "entries" => entries}
      end

      {"type" => "hash", "entries" => extract_messages_dat_entries(section)}
    end

    def self.extract_messages_dat_entries(messages)
      entries = {}
      each_message_pair(messages) do |source, target, entry_index|
        entries["line_" + zero_pad(entry_index, 4)] = {
          "source" => source.to_s,
          "target" => target.to_s
        }
      end
      entries
    end

    def self.migrate_messages_dat_section(section, namespace, section_name, flat, source_text)
      if section_name == "maps" && section.is_a?(Array)
        section.each_with_index do |messages, map_index|
          next if messages.nil?
          migrate_messages_dat_hash(messages, namespace + ".maps.map_" + zero_pad(map_index, 4), flat, source_text)
        end
      elsif section.is_a?(Array)
        section.each_with_index do |value, entry_index|
          next if value.nil? || value == ""
          flat[namespace + "." + section_name + ".id_" + zero_pad(entry_index, 4)] = migrate_message_text(value)
        end
      else
        migrate_messages_dat_hash(section, namespace + "." + section_name, flat, source_text)
      end
    end

    def self.migrate_messages_dat_hash(messages, prefix, flat, source_text)
      each_message_pair(messages) do |source, target, entry_index|
        key = prefix + ".line_" + zero_pad(entry_index, 4)
        source_text[source.to_s] = key unless source.to_s == ""
        flat[key] = migrate_message_text(target)
      end
    end

    def self.each_message_pair(messages)
      if messages.respond_to?(:keys)
        index = 1
        messages.keys.each do |key|
          yield key, messages[key], index
          index += 1
        end
      end
    end

    def self.migrate_message_text(value)
      replacements = []
      text = value.to_s.gsub("'", "''")
      text = text.gsub(/\{([0-9]+)(?:\:[^\}]+)?\}/) do |match|
        replacements << "{arg" + $1 + "}"
        "\001" + (replacements.length - 1).to_s + "\001"
      end
      text = text.gsub("{", "'{'").gsub("}", "'}'")
      replacements.each_with_index do |replacement, index|
        text = text.gsub("\001" + index.to_s + "\001", replacement)
      end
      text
    end

    def self.pbs_entry(fields)
      entry = {}
      entry["name"] = fields[2] if fields[2] && fields[2] != ""
      entry["description"] = fields[fields.length - 1] if fields.length > 3 && fields[fields.length - 1] != ""
      entry
    end

    def self.split_csv_line(line)
      fields = []
      field = ""
      quoted = false
      index = 0
      while index < line.length
        char = line[index, 1]
        if quoted
          if char == "\"" && line[index + 1, 1] == "\""
            field << "\""
            index += 2
          elsif char == "\""
            quoted = false
            index += 1
          else
            field << char
            index += 1
          end
        elsif char == "\""
          quoted = true
          index += 1
        elsif char == ","
          fields << field
          field = ""
          index += 1
        else
          field << char
          index += 1
        end
      end
      fields << field
      fields
    end

    def self.normalize_identifier(value)
      value.to_s.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+/, "").gsub(/_+\z/, "")
    end

    def self.zero_pad(value, width)
      text = value.to_s
      text = "0" + text while text.length < width
      text
    end

    def self.xliff(locale, catalog)
      body = flatten(catalog).keys.sort.collect do |key|
        value = flatten(catalog)[key]
        "      <unit id=\"" + xml_escape(key) + "\"><segment><target xml:lang=\"" + xml_escape(locale) + "\">" + xml_escape(value) + "</target></segment></unit>"
      end.join("\n")
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<xliff version=\"2.1\" srcLang=\"en\" trgLang=\"" + xml_escape(locale) + "\">\n  <file id=\"catalog\">\n" + body + "\n  </file>\n</xliff>\n"
    end

    def self.po(catalog)
      flatten(catalog).keys.sort.collect do |key|
        value = flatten(catalog)[key]
        "msgctxt " + quote(key) + "\nmsgid " + quote(value) + "\nmsgstr " + quote(value) + "\n"
      end.join("\n")
    end

    def self.parse_xliff(source)
      result = {}
      source.scan(/<unit id="([^"]+)">.*?<target[^>]*>(.*?)<\/target>.*?<\/unit>/m) do |key, value|
        result[xml_unescape(key)] = xml_unescape(value)
      end
      result
    end

    def self.parse_po(source)
      result = {}
      source.split(/\n\n+/).each do |entry|
        context = entry[/msgctxt\s+"((?:\\"|[^"])*)"/, 1]
        translated = entry[/msgstr\s+"((?:\\"|[^"])*)"/, 1]
        result[unquote(context)] = unquote(translated) if context && translated
      end
      result
    end

    def self.xml_escape(value)
      value.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("\"", "&quot;")
    end

    def self.xml_unescape(value)
      value.to_s.gsub("&quot;", "\"").gsub("&gt;", ">").gsub("&lt;", "<").gsub("&amp;", "&")
    end

    def self.unquote(value)
      value.to_s.gsub("\\n", "\n").gsub("\\t", "\t").gsub("\\\"", "\"").gsub("\\\\", "\\")
    end

    def self.flatten_into(catalog, path, result)
      catalog.each do |key, value|
        current_path = path + [key.to_s]
        if value.is_a?(Hash)
          flatten_into(value, current_path, result)
        else
          result[current_path.join(".")] = value
        end
      end
    end

    def self.transform_leaves(catalog, &block)
      result = {}
      catalog.each do |key, value|
        result[key] = value.is_a?(Hash) ? transform_leaves(value, &block) : yield(value)
      end
      result
    end

    def self.read_braced(message, start)
      depth = 0
      index = start
      while index < message.length
        char = message[index, 1]
        depth += 1 if char == "{"
        depth -= 1 if char == "}"
        index += 1
        break if depth == 0
      end
      [message[start, index - start], index]
    end

    def self.pseudo_char(char)
      lower = char.downcase
      return ACCENTS[lower] || char if lower != char
      ACCENTS[char] || char
    end
  end
end
