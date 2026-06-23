module Kotoba
  module CatalogLoader
    def self.read_file(config, path)
      if config.file_loader
        return config.file_loader.call(path)
      end

      normalized = normalize_path(path)
      file = File.open(normalized, "rb")
      begin
        file.read
      ensure
        file.close
      end
    end

    def self.check_size(config, path, bytes, loaded_bytes)
      if bytes > config.max_catalog_bytes
        raise CatalogError, "catalog is too large: " + path.to_s
      end
      if bytes > config.warn_catalog_bytes
        warn_runtime(config, "catalog is large: " + path.to_s + " (" + bytes.to_s + " bytes)")
      end
      loaded_bytes = 0 if loaded_bytes.nil?
      loaded_bytes += bytes
      if loaded_bytes > config.max_loaded_catalog_bytes
        raise CatalogError, "loaded catalog bytes exceed configured limit"
      end
      loaded_bytes
    end

    def self.discover_paths(config, locale_value)
      paths = []
      (config.catalog_discovery_paths || []).each do |root|
        normalized_root = normalize_path(root)
        direct = File.join(normalized_root, locale_value.to_s + ".json")
        paths << direct if file_exists?(direct)
        Dir[File.join(normalized_root, locale_value.to_s, "*.json")].sort.each do |path|
          paths << path
        end
      end
      paths
    end

    def self.normalize_path(path)
      path.to_s.gsub("\\", "/")
    end

    def self.file_exists?(path)
      File.file?(normalize_path(path))
    end

    def self.warn_runtime(config, message)
      if config.warning_handler
        config.warning_handler.call(message)
      end
    end
  end
end
