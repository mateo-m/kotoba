kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

module KotobaTools
  module CatalogTools
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
  end
end
