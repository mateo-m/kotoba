require File.join(File.dirname(__FILE__), "json")

module Kotoba
  module DocsRouting
    ROUTING_PATH = File.expand_path(File.join(File.dirname(__FILE__), "..", "docs", "routing.json"))

    def self.load!
      return if @loaded
      source = File.open(ROUTING_PATH, "rb") { |file| file.read }
      parsed = JSON.parse(source, {"max_depth" => 8, "duplicate_keys" => "error"})
      @install_path = parsed["install_path"].to_s
      @version_path_template = parsed["version_path_template"].to_s
      @loaded = true
    end

    def self.install_path
      load!
      @install_path
    end

    def self.version_path_template
      load!
      @version_path_template
    end

    def self.versioned_install_path(version)
      version_path_template.
        gsub("{version}", version.to_s).
        gsub("{install_path}", install_path)
    end

    def self.install_url(site_url, version)
      site_url.to_s.sub(/\/\z/, "") + "/" + versioned_install_path(version)
    end
  end
end
