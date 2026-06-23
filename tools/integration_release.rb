kotoba_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "kotoba"))
$LOAD_PATH.unshift(kotoba_path) unless $LOAD_PATH.include?(kotoba_path)

require "fileutils"
require File.join(kotoba_path, "docs_routing")

module KotobaTools
  module IntegrationRelease
    PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))
    VERSION_PATH = File.join(PROJECT_ROOT, "kotoba", "VERSION")
    KOTOBA_RUNTIME_FILES = Dir[File.join(PROJECT_ROOT, "kotoba", "*.rb")].find_all do |path|
      File.file?(path) && File.basename(path) != "boot.rb"
    end.collect do |path|
      path.sub(PROJECT_ROOT + "/", "")
    end.sort + ["kotoba/VERSION"]

    SCRIPT_EDITOR_FILES = Dir[File.join(PROJECT_ROOT, "kotoba", "samples", "script_editor", "**", "*")].find_all do |path|
      File.file?(path)
    end.collect do |path|
      path.sub(PROJECT_ROOT + "/", "")
    end.sort

    ADAPTER_TARGETS = {
      "bare_rgss" => {
        "zip_name" => "kotoba-bare-rgss.zip",
        "adapter_files" => ["kotoba/adapters/registry.rb", "kotoba/adapters/bare_rgss.rb"],
        "example_catalog" => "kotoba/samples/bare_rgss/en.json"
      },
      "essentials_bes" => {
        "zip_name" => "kotoba-essentials-bes.zip",
        "adapter_files" => ["kotoba/adapters/registry.rb", "kotoba/adapters/essentials_base.rb", "kotoba/adapters/essentials_bes.rb"],
        "example_catalog" => "kotoba/samples/pokemon_essentials/en.json"
      },
      "essentials_v16" => {
        "zip_name" => "kotoba-essentials-v16.zip",
        "adapter_files" => ["kotoba/adapters/registry.rb", "kotoba/adapters/essentials_base.rb", "kotoba/adapters/essentials_v16.rb"],
        "example_catalog" => "kotoba/samples/pokemon_essentials/en.json"
      },
      "essentials_v17" => {
        "zip_name" => "kotoba-essentials-v17.zip",
        "adapter_files" => ["kotoba/adapters/registry.rb", "kotoba/adapters/essentials_base.rb", "kotoba/adapters/essentials_v17.rb"],
        "example_catalog" => "kotoba/samples/pokemon_essentials/en.json"
      },
      "essentials_v18" => {
        "zip_name" => "kotoba-essentials-v18.zip",
        "adapter_files" => ["kotoba/adapters/registry.rb", "kotoba/adapters/essentials_base.rb", "kotoba/adapters/essentials_v18.rb"],
        "example_catalog" => "kotoba/samples/pokemon_essentials/en.json"
      },
      "essentials_v19" => {
        "zip_name" => "kotoba-essentials-v19.zip",
        "adapter_files" => ["kotoba/adapters/registry.rb", "kotoba/adapters/essentials_base.rb", "kotoba/adapters/essentials_v19.rb"],
        "example_catalog" => "kotoba/samples/pokemon_essentials/en.json"
      },
      "essentials_v20" => {
        "zip_name" => "kotoba-essentials-v20.zip",
        "adapter_files" => ["kotoba/adapters/registry.rb", "kotoba/adapters/essentials_base.rb", "kotoba/adapters/essentials_v20.rb"],
        "example_catalog" => "kotoba/samples/pokemon_essentials/en.json"
      },
      "essentials_v21" => {
        "zip_name" => "kotoba-essentials-v21.zip",
        "adapter_files" => ["kotoba/adapters/registry.rb", "kotoba/adapters/essentials_v21.rb"],
        "example_catalog" => "kotoba/samples/pokemon_essentials/en.json"
      }
    }

    def self.version
      File.open(VERSION_PATH, "rb") { |file| file.read }.strip
    end

    def self.target_names
      ADAPTER_TARGETS.keys.sort
    end

    def self.target(name)
      ADAPTER_TARGETS[name.to_s]
    end

    def self.package_relative_files(adapter_name)
      config = target(adapter_name)
      raise ArgumentError, "unknown adapter " + adapter_name.to_s if config.nil?

      files = KOTOBA_RUNTIME_FILES + config["adapter_files"] + SCRIPT_EDITOR_FILES + [
        config["example_catalog"],
        "kotoba/boot.rb",
        "INSTALL.md",
        "MANIFEST.json"
      ]
      files.sort
    end

    def self.docs_site_url
      explicit = ENV["KOTOBA_DOCS_URL"]
      return explicit.sub(/\/\z/, "") unless explicit.nil? || explicit.empty?

      script = File.join(PROJECT_ROOT, "bin", "docs-site-url")
      url = `sh #{script.shellescape} 2>/dev/null`.strip
      return url unless url.empty?

      raise "Set KOTOBA_DOCS_URL or configure a GitHub origin remote for docs URLs"
    end

    def self.docs_install_url
      Kotoba::DocsRouting.install_url(docs_site_url, version)
    end

    def self.manifest(adapter_name, files = nil)
      listed = files || package_relative_files(adapter_name)
      {
        "kotoba_version" => version,
        "adapter" => adapter_name.to_s,
        "docs_install_url" => docs_install_url,
        "files" => listed
      }
    end

    def self.install_markdown(adapter_name)
      config = target(adapter_name)
      raise ArgumentError, "unknown adapter " + adapter_name.to_s if config.nil?

      sample_catalog = config["example_catalog"]
      adapter_file = config["adapter_files"].find { |path| path =~ /#{adapter_name}\.rb\z/ }
      adapter_basename = File.basename(adapter_file)
      smoke_test = if adapter_name == "bare_rgss"
        "kotoba/samples/script_editor/bare_rgss_smoke_test.rb"
      else
        "kotoba/samples/script_editor/essentials_smoke_test.rb"
      end

      <<MARKDOWN
# Kotoba #{version} — #{adapter_name}

Extract this archive into the folder that contains `Game.exe`.

## Install guide

#{docs_install_url}

This install guide matches Kotoba #{version} in this ZIP.

## This package

| Item | Value |
| --- | --- |
| Adapter | `#{adapter_name}` |
| Adapter file | `#{adapter_basename}` |
| Sample catalog | `#{sample_catalog}` |
| Script Editor smoke test | `load "#{smoke_test}"` |
| Script examples | `kotoba/samples/script_editor/` |
| File list | `MANIFEST.json` |
| Install URL | `docs_install_url` in `MANIFEST.json` |
MARKDOWN
    end

    def self.boot_ruby(adapter_name)
      config = target(adapter_name)
      raise ArgumentError, "unknown adapter " + adapter_name.to_s if config.nil?

      adapter_file = config["adapter_files"].find { |path| path =~ /#{adapter_name}\.rb\z/ }
      catalog_path = config["example_catalog"]

      lines = []
      lines << "# Kotoba boot script — generated for #{adapter_name}"
      lines << "#"
      lines << "# HOW TO USE (read this):"
      lines << "# 1. This file must sit at kotoba/boot.rb next to Game.exe."
      lines << "# 2. Do NOT double-click this file. RPG Maker does not run it that way."
      lines << "# 3. In RPG Maker: Tools -> Script Editor -> new section named Kotoba -> add:"
      lines << "#      load \"kotoba/boot.rb\""
      lines << "# 4. Click OK to save scripts, then playtest."
      lines << "#"
      lines << "# catalog_paths below loads the sample JSON at #{catalog_path}."
      lines << "# Docs: #{docs_install_url}"
      lines << ""
      lines << "require File.join(\".\", \"kotoba\", \"core\")"
      lines << "require File.join(\".\", \"kotoba\", \"adapters\", \"" + File.basename(adapter_file) + "\")"
      lines << ""
      lines << "Kotoba.configure do |config|"
      lines << "  config.default_locale = \"en\""
      lines << "  config.available_locales = [\"en\"]"
      lines << "  # Locale code => JSON file path(s) relative to the game folder (where Game.exe is)."
      lines << "  config.catalog_paths = {"
      lines << "    \"en\" => [\"" + catalog_path + "\"]"
      lines << "  }"
      lines << "end"
      lines << ""
      lines << "# Loads catalogs and activates the #{adapter_name} adapter."
      lines << "Kotoba.use_adapter(\"#{adapter_name}\", {\"load\" => true})"
      lines.join("\n") + "\n"
    end

    def self.stage_package(staging_root, adapter_name)
      config = target(adapter_name)
      raise ArgumentError, "unknown adapter " + adapter_name.to_s if config.nil?

      FileUtils.rm_rf(staging_root)
      FileUtils.mkdir_p(staging_root)

      package_relative_files(adapter_name).each do |relative|
        next if relative == "INSTALL.md" || relative == "MANIFEST.json"
        next if relative == "kotoba/boot.rb"
        source = File.join(PROJECT_ROOT, relative)
        destination = File.join(staging_root, relative)
        FileUtils.mkdir_p(File.dirname(destination))
        if File.directory?(source)
          FileUtils.cp_r(source, destination)
        else
          FileUtils.cp(source, destination)
        end
      end

      destination = File.join(staging_root, "kotoba", "boot.rb")
      FileUtils.mkdir_p(File.dirname(destination))
      File.open(destination, "wb") { |file| file.write(boot_ruby(adapter_name)) }

      files = Dir[File.join(staging_root, "**", "*")].find_all { |path| File.file?(path) }.collect do |path|
        path.sub(staging_root + "/", "")
      end.sort

      File.open(File.join(staging_root, "INSTALL.md"), "wb") do |file|
        file.write(install_markdown(adapter_name))
      end
      require File.join(PROJECT_ROOT, "tools", "catalog_tools")
      KotobaTools::CatalogTools.write_json(
        File.join(staging_root, "MANIFEST.json"),
        manifest(adapter_name, files)
      )

      files
    end

    def self.build_zip(output_dir, adapter_name)
      config = target(adapter_name)
      raise ArgumentError, "unknown adapter " + adapter_name.to_s if config.nil?

      FileUtils.mkdir_p(output_dir)
      staging_root = File.join(output_dir, ".staging-" + adapter_name)
      stage_package(staging_root, adapter_name)
      zip_path = File.expand_path(File.join(output_dir, config["zip_name"]))
      File.delete(zip_path) if File.exist?(zip_path)

      command = "cd " + staging_root.shellescape + " && zip -rq " + zip_path.shellescape + " ."
      unless system(command)
        raise "zip command failed for " + adapter_name.to_s
      end
      FileUtils.rm_rf(staging_root)
      zip_path
    end

    def self.build_all(output_dir)
      target_names.collect do |name|
        build_zip(output_dir, name)
      end
    end
  end
end

class String
  def shellescape
    return "''" if self == ""
    if self =~ /\A[a-zA-Z0-9_\/.,+-]+\z/
      self
    else
      "'" + self.gsub("'", "'\\\\''") + "'"
    end
  end unless method_defined?(:shellescape)
end
