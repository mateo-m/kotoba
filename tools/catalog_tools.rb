kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
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

module KotobaTools
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
    PBS_PROFILES = {
      "moves" => {"name" => 2, "description" => -1},
      "items" => {"name" => 2, "name_plural" => 3, "description" => 6},
      "abilities" => {"name" => 2, "description" => 3}
    }
    PBS_SECTION_PROFILES = {
      "pokemon" => {
        "Name" => "name",
        "Kind" => "kind",
        "Pokedex" => "pokedex",
        "FormName" => "form_name"
      },
      "types" => {
        "Name" => "name"
      },
      "trainers" => {
        "LoseText" => "lose_text",
        "EndSpeech" => "end_speech",
        "EndBattle" => "end_battle",
        "RegSpeech" => "reg_speech"
      }
    }

    def self.load_json(path)
      Kotoba::JSON.parse(File.open(path, "rb") { |file| file.read }, {
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
      if PBS_SECTION_PROFILES.has_key?(namespace.to_s)
        return extract_pbs_sections(namespace, path, PBS_SECTION_PROFILES[namespace.to_s])
      end
      profile = PBS_PROFILES[namespace.to_s] || PBS_PROFILES["moves"]
      entries = {}
      File.open(path, "rb") do |file|
        file.each_line do |line|
          row = line.strip
          next if row == "" || row[0, 1] == "#" || row[0, 1] == "["
          fields = split_csv_line(row)
          next if fields.length < 2
          id = normalize_identifier(fields[1] || fields[0])
          entries[id] = pbs_entry(fields, profile)
        end
      end
      {"data" => {namespace.to_s => entries}}
    end

    def self.extract_pbs_sections(namespace, path, field_map)
      entries = {}
      current = {}
      current_id = nil
      File.open(path, "rb") do |file|
        file.each_line do |line|
          text = line.sub(/#.*$/, "").strip
          next if text == ""
          if text[0, 1] == "[" && text[-1, 1] == "]"
            store_pbs_section_entry(entries, current_id, current, namespace)
            current_id = text[1...-1]
            current = section_header_fields(namespace, current_id)
          elsif text =~ /\A([^=]+)=(.*)\z/
            key = $1.strip
            value = $2.strip
            if field_map.has_key?(key)
              current[field_map[key]] = value
            end
            if key == "InternalName"
              current["internal_name"] = value
            end
          end
        end
      end
      store_pbs_section_entry(entries, current_id, current, namespace)
      {"data" => {namespace.to_s => entries}}
    end

    def self.section_header_fields(namespace, section_id)
      fields = {}
      if namespace.to_s == "trainers"
        parts = section_id.to_s.split(",")
        fields["trainer_type"] = parts[0].strip if parts[0]
        fields["trainer_name"] = parts[1].strip if parts[1]
        fields["version"] = parts[2].strip if parts[2]
      end
      fields
    end

    def self.store_pbs_section_entry(entries, section_id, current, namespace = nil)
      return if current.empty?

      id = current["internal_name"] || section_id
      return if id.nil? || id == ""

      entry = current.dup
      entry.delete("internal_name")
      entries[normalize_identifier(id)] = entry
    end

    def self.import_text_english(path, namespace)
      source_text = {}
      flat = {}
      current_section = "default"
      index = 1
      pending = nil
      File.open(path, "rb") do |file|
        file.each_line do |line|
          text = line.chomp
          next if text == "" || text[0, 1] == "#"
          if text[0, 1] == "[" && text[-1, 1] == "]"
            current_section = normalize_identifier(text[1...-1])
            index = 1
            pending = nil
            next
          end
          if pending.nil?
            pending = text
          else
            key = namespace.to_s + "." + current_section + ".line_" + zero_pad(index, 4)
            source_text[pending] = key
            flat[key] = text == "" ? pending : text
            index += 1
            pending = nil
          end
        end
      end
      result = unflatten(flat)
      result["source_text"] = source_text unless source_text.empty?
      result
    end

    def self.import_text_english_dir(path, namespace)
      result = {}
      source_text = {}
      return result unless File.directory?(path)

      Dir.glob(File.join(path, "*.txt")).sort.each do |file_path|
        file_key = normalize_identifier(File.basename(file_path, ".txt"))
        partial = import_text_english(file_path, namespace.to_s + "." + file_key)
        partial_source_text = partial["source_text"]
        partial = partial.dup
        partial.delete("source_text")
        merge_nested_hash(result, partial)
        if partial_source_text
          partial_source_text.each do |source, key|
            source_text[source] = key
          end
        end
      end
      result["source_text"] = source_text unless source_text.empty?
      result
    end

    def self.load_map_rxdata(path)
      require File.expand_path(File.join(File.dirname(__FILE__), "rgss_rxdata_stubs"))
      data = File.open(path, "rb") { |file| file.read }
      load_marshal_with_stubs(data)
    end

    def self.load_marshal_with_stubs(data)
      attempts = 0
      begin
        Marshal.load(data)
      rescue ArgumentError
        error = $!
        if attempts < 64 && error.message =~ /undefined class\/module (.+)$/
          define_marshal_stub($1)
          attempts += 1
          retry
        end
        raise error
      end
    end

    def self.define_marshal_stub(name)
      parts = name.split("::")
      cursor = Object
      parts.each do |part|
        unless cursor.const_defined?(part)
          klass = Class.new
          klass.class_eval do
            def self._load(_data)
              new
            end
          end
          cursor.const_set(part, klass)
        end
        cursor = cursor.const_get(part)
      end
    end

    def self.extract_map_rxdata(path)
      map = load_map_rxdata(path)
      map_id = normalize_map_id(path)
      events = {}
      each_map_event_text(map) do |event_id, event_name, page_index, command_code, lines|
        event_key = "event_" + zero_pad(event_id, 4)
        events[event_key] ||= {"name" => event_name.to_s, "pages" => {}}
        page_key = "page_" + zero_pad(page_index + 1, 2)
        events[event_key]["pages"][page_key] ||= {"commands" => []}
        events[event_key]["pages"][page_key]["commands"] << {
          "code" => command_code,
          "lines" => lines
        }
      end
      {
        "format" => "rpg_maker_xp_map",
        "map_id" => map_id,
        "event_count" => events.length,
        "events" => events
      }
    end

    def self.import_map_rxdata(path, namespace)
      map_id = normalize_map_id(path)
      flat = {}
      source_text = {}
      line_index = 1
      each_map_event_text(load_map_rxdata(path)) do |event_id, _event_name, _page_index, _command_code, lines|
        lines.each do |line|
          next if line.nil? || line == ""
          key = namespace.to_s + ".maps." + map_id + ".event_" + zero_pad(event_id, 4) + ".line_" + zero_pad(line_index, 4)
          source_text[line] = key
          flat[key] = line
          line_index += 1
        end
      end
      result = unflatten(flat)
      result["source_text"] = source_text unless source_text.empty?
      result
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

    def self.pbs_entry(fields, profile)
      entry = {}
      profile.each do |key, index|
        value = pbs_field(fields, index)
        entry[key] = value if value && value != ""
      end
      entry
    end

    def self.pbs_field(fields, index)
      position = index < 0 ? fields.length + index : index
      return nil if position < 0 || position >= fields.length
      fields[position]
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

    def self.normalize_map_id(path)
      base = File.basename(path.to_s, ".rxdata")
      if base =~ /\AMap(\d+)\z/i
        return "map_" + zero_pad($1.to_i, 4)
      end
      normalize_identifier(base)
    end

    def self.each_map_event_text(map)
      return unless map && map.events

      map.events.each do |event_id, event|
        next unless event && event.pages
        event.pages.each_with_index do |page, page_index|
          next unless page && page.list.is_a?(Array)
          page.list.each do |command|
            next unless command
            lines = extract_event_command_text(command)
            next if lines.empty?
            yield event_id, event.name, page_index, command.code, lines
          end
        end
      end
    end

    def self.extract_event_command_text(command)
      return [] unless command && command.parameters.is_a?(Array)

      code = command.code
      params = command.parameters
      if code == 101
        lines = params.length > 4 ? params[4..-1] : []
        lines = [] if lines.nil?
        return lines.collect { |line| line.to_s }.find_all { |line| line != "" }
      end
      if code == 401
        return params.collect { |line| line.to_s }.find_all { |line| line != "" }
      end
      if code == 108
        text = params[0].to_s
        intl = extract_script_intl_sources(text)
        return intl unless intl.empty?
        return [text].find_all { |line| line != "" }
      end
      if code == 102
        start = numeric_pbs_value?(params[0]) ? 1 : 0
        lines = []
        index = start
        while index < params.length
          param = params[index]
          lines << param.to_s if param.is_a?(String) && param != ""
          index += 1
        end
        return lines
      end
      if code == 355 || code == 356 || code == 655 || code == 657
        script = params[0].to_s
        return [] if script == ""
        intl = extract_script_intl_sources(script)
        return intl unless intl.empty?
        return []
      end
      []
    end

    def self.extract_script_intl_sources(script)
      result = []
      script.scan(/_INTL\s*\(\s*"((?:\\"|[^"])*)"/) do
        result << unquote($1)
      end
      script.scan(/_INTL\s*\(\s*'((?:\\'|[^'])*)'/) do
        result << unquote($1)
      end
      script.scan(/_ISPRINTF\s*\(\s*"((?:\\"|[^"])*)"/) do
        result << unquote($1)
      end
      script.scan(/_ISPRINTF\s*\(\s*'((?:\\'|[^'])*)'/) do
        result << unquote($1)
      end
      result
    end

    def self.numeric_pbs_value?(value)
      value.to_s =~ /\A-?\d+\z/
    end

    def self.merge_nested_hash(target, source)
      source.each do |key, value|
        if value.is_a?(Hash) && target[key].is_a?(Hash)
          merge_nested_hash(target[key], value)
        else
          target[key] = value
        end
      end
    end
  end
end
