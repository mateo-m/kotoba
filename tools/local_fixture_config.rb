module LocalFixtureConfig
  def self.project_root
    File.expand_path("..", File.dirname(__FILE__))
  end

  def self.config_path
    File.join(project_root, "test", "fixtures.local.yml")
  end

  def self.load
    path = config_path
    return {} unless File.file?(path)

    games = {}
    current_key = nil
    File.open(path, "rb") do |file|
      file.each_line do |line|
        text = line.sub(/#.*$/, "").strip
        next if text == ""

        if text == "games:"
          next
        end

        if text =~ /\A([A-Za-z0-9_]+):\s*(.*)\z/
          current_key = $1
          value = $2
          games[current_key] = value unless value == ""
          next
        end

        if current_key && text =~ /\A\/.*\z/
          games[current_key] = text
        end
      end
    end

    {"games" => games}
  end

  def self.game_path(name)
    config = load()
    games = config["games"]
    return nil unless games.is_a?(Hash)

    path = games[name.to_s]
    return nil if path.nil? || path == ""

    path
  end
end
