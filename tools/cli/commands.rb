require "cli/registry"

module KotobaTools
  module CLI
    register "load-test" do |argv, context|
      argv.length > 0 && context.validator.load_test(argv)
    end

    register "validate" do |argv, context|
      human = context.shift_human_flag?(argv)
      source = argv.shift
      source && argv.length > 0 && context.validator.validate(source, argv, human)
    end

    register "validate-report" do |argv, context|
      human = context.shift_human_flag?(argv)
      output = argv.pop
      source = argv.shift
      if output && source && argv.length > 0
        context.validator.validate(source, argv, human)
        KotobaTools::CatalogTools.write_json(output, context.validator.report)
        context.validator.errors.empty?
      else
        false
      end
    end

    register "schema" do |argv, context|
      schema_name = argv.shift
      path = argv.shift
      schema_name && path && context.validator.schema(schema_name, path)
    end

    register "pbs-extract" do |argv, _context|
      namespace = argv.shift
      input = argv.shift
      output = argv.shift
      if namespace && input && output
        KotobaTools::CatalogTools.write_json(output, KotobaTools::CatalogTools.extract_pbs(namespace, input))
        true
      else
        false
      end
    end

    register "messages-dat-extract" do |argv, _context|
      input = argv.shift
      output = argv.shift
      if input && output
        KotobaTools::CatalogTools.write_json(output, KotobaTools::CatalogTools.extract_messages_dat(input))
        true
      else
        false
      end
    end

    register "messages-dat-migrate" do |argv, _context|
      input = argv.shift
      namespace = argv.shift
      output = argv.shift
      if input && namespace && output
        KotobaTools::CatalogTools.write_json(output, KotobaTools::CatalogTools.migrate_messages_dat(input, namespace))
        true
      else
        false
      end
    end

    register "essentials-pairs-import" do |argv, _context|
      input = argv.shift
      namespace = argv.shift
      output = argv.shift
      if input && namespace && output
        KotobaTools::CatalogTools.write_json(output, KotobaTools::CatalogTools.import_essentials_pairs(input, namespace))
        true
      else
        false
      end
    end

    register "text-english-import" do |argv, _context|
      input = argv.shift
      namespace = argv.shift
      output = argv.shift
      if input && namespace && output
        catalog = File.directory?(input) ?
          KotobaTools::CatalogTools.import_text_english_dir(input, namespace) :
          KotobaTools::CatalogTools.import_text_english(input, namespace)
        KotobaTools::CatalogTools.write_json(output, catalog)
        true
      else
        false
      end
    end

    register "map-rxdata-extract" do |argv, _context|
      input = argv.shift
      output = argv.shift
      if input && output
        KotobaTools::CatalogTools.write_json(output, KotobaTools::CatalogTools.extract_map_rxdata(input))
        true
      else
        false
      end
    end

    register "map-rxdata-import" do |argv, _context|
      input = argv.shift
      namespace = argv.shift
      output = argv.shift
      if input && namespace && output
        KotobaTools::CatalogTools.write_json(output, KotobaTools::CatalogTools.import_map_rxdata(input, namespace))
        true
      else
        false
      end
    end

    register "flat-export" do |argv, _context|
      input = argv.shift
      output = argv.shift
      if input && output
        KotobaTools::CatalogTools.write_json(
          output,
          KotobaTools::CatalogTools.flatten(KotobaTools::CatalogTools.load_json(input))
        )
        true
      else
        false
      end
    end

    register "flat-import" do |argv, _context|
      input = argv.shift
      output = argv.shift
      if input && output
        KotobaTools::CatalogTools.write_json(
          output,
          KotobaTools::CatalogTools.unflatten(KotobaTools::CatalogTools.load_json(input))
        )
        true
      else
        false
      end
    end

    register "spreadsheet-export" do |argv, context|
      source = argv.shift
      output = argv.shift
      metadata = argv[0] && File.file?(argv[0]) ? argv.shift : nil
      locale = argv[0] && File.file?(argv[0]) ? argv.shift : nil
      if source && output
        begin
          source_catalog = KotobaTools::CatalogTools.load_json(source)
          locale_catalog = locale ? KotobaTools::CatalogTools.load_json(locale) : nil
          metadata_catalog = metadata ? KotobaTools::CatalogTools.load_json(metadata) : nil
          File.open(output, "wb") do |file|
            file.write(KotobaTools::CatalogTools.spreadsheet_export(source_catalog, locale_catalog, metadata_catalog))
          end
          true
        rescue ArgumentError => error
          context.validator.errors << error.message
          false
        end
      else
        false
      end
    end

    register "spreadsheet-import" do |argv, context|
      source = argv.shift
      input = argv.shift
      output = argv.shift
      if source && input && output
        begin
          source_catalog = KotobaTools::CatalogTools.load_json(source)
          csv_source = File.open(input, "rb") { |file| file.read }
          KotobaTools::CatalogTools.write_json(output, KotobaTools::CatalogTools.spreadsheet_import(source_catalog, csv_source))
          true
        rescue ArgumentError => error
          context.validator.errors << error.message
          false
        end
      else
        false
      end
    end

    register "pseudo" do |argv, _context|
      input = argv.shift
      output = argv.shift
      if input && output
        KotobaTools::CatalogTools.write_json(
          output,
          KotobaTools::CatalogTools.pseudolocalize_catalog(KotobaTools::CatalogTools.load_json(input))
        )
        true
      else
        false
      end
    end

    register "tms-export" do |argv, _context|
      profile = argv.shift
      locale = argv.shift
      input = argv.shift
      output = argv.shift
      if profile && locale && input && output
        exported = KotobaTools::CatalogTools.export_profile(profile, locale, KotobaTools::CatalogTools.load_json(input))
        if exported.is_a?(String)
          File.open(output, "wb") { |file| file.write(exported) }
        else
          KotobaTools::CatalogTools.write_json(output, exported)
        end
        true
      else
        false
      end
    end

    register "tms-import" do |argv, _context|
      profile = argv.shift
      locale = argv.shift
      input = argv.shift
      output = argv.shift
      if profile && locale && input && output
        source = profile == "xliff" || profile == "po" ?
          File.open(input, "rb") { |file| file.read } :
          KotobaTools::CatalogTools.load_json(input)
        KotobaTools::CatalogTools.write_json(output, KotobaTools::CatalogTools.import_profile(profile, locale, source))
        true
      else
        false
      end
    end

    register "handoff" do |argv, _context|
      output_dir = argv.shift
      locale = argv.shift
      source = argv.shift
      metadata = argv.shift
      if output_dir && locale && source
        KotobaTools::CatalogTools.write_handoff_package(output_dir, locale, source, metadata)
        true
      else
        false
      end
    end
  end
end
