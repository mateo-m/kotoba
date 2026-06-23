kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "core"
require "fileutils"

module KotobaTools
  module CatalogTools
    def self.load_map_rxdata(path)
      require File.expand_path(File.join(File.dirname(__FILE__), "..", "rgss_rxdata_stubs"))
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
        return extract_choice_lines(params)
      end
      if code == 402
        if params.length > 1 && params[1].is_a?(String)
          return [params[1]].find_all { |line| line != "" }
        end
        if params[0].is_a?(String)
          return [params[0]].find_all { |line| line != "" }
        end
        return []
      end
      if code == 408
        text = params[0].to_s
        intl = extract_script_intl_sources(text)
        return intl unless intl.empty?
        return [text].find_all { |line| line != "" }
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

    def self.extract_choice_lines(params)
      lines = []
      params.each do |param|
        if param.is_a?(Array)
          param.each do |choice|
            lines << choice.to_s if choice.is_a?(String) && choice != ""
          end
        elsif param.is_a?(String) && param != ""
          lines << param.to_s
        end
      end
      lines
    end

    def self.numeric_pbs_value?(value)
      value.to_s =~ /\A-?\d+\z/
    end
  end
end
