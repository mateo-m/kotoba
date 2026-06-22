module RGSSI18n
  class Config
    attr_accessor :source_locale
    attr_accessor :default_locale
    attr_accessor :available_locales
    attr_accessor :locale_names
    attr_accessor :catalog_paths
    attr_accessor :catalog_discovery_paths
    attr_accessor :fallbacks
    attr_accessor :strict
    attr_accessor :diagnostics
    attr_accessor :diagnostics_file
    attr_accessor :show_missing_keys
    attr_accessor :global_helper
    attr_accessor :i18n_alias
    attr_accessor :warn_catalog_bytes
    attr_accessor :max_catalog_bytes
    attr_accessor :max_loaded_catalog_bytes
    attr_accessor :max_json_depth
    attr_accessor :max_message_depth
    attr_accessor :duplicate_key_policy
    attr_accessor :missing_variable_policy
    attr_accessor :file_loader
    attr_accessor :missing_handler
    attr_accessor :warning_handler
    attr_accessor :locale_change_handler

    def initialize
      @source_locale = "en"
      @default_locale = "en"
      @available_locales = ["en"]
      @locale_names = {"en" => "English"}
      @catalog_paths = {}
      @catalog_discovery_paths = []
      @fallbacks = {"default" => ["en"]}
      @strict = false
      @diagnostics = false
      @diagnostics_file = "i18n_missing.log"
      @show_missing_keys = false
      @global_helper = true
      @i18n_alias = false
      @warn_catalog_bytes = 4 * 1024 * 1024
      @max_catalog_bytes = 8 * 1024 * 1024
      @max_loaded_catalog_bytes = 32 * 1024 * 1024
      @max_json_depth = 64
      @max_message_depth = 16
      @duplicate_key_policy = "override"
      @missing_variable_policy = "keep"
      @file_loader = nil
      @missing_handler = nil
      @warning_handler = nil
      @locale_change_handler = nil
    end
  end
end
