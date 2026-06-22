require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

tool_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "tools", "validators"))
$LOAD_PATH.unshift(tool_path) unless $LOAD_PATH.include?(tool_path)
require "catalog_validator"

class ValidatorTest < KotobaTestCase
  FIXTURE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "fixtures", "validator"))

  def validator
    KotobaTools::CatalogValidator.new
  end

  def fixture(name)
    File.join(FIXTURE_ROOT, name)
  end

  def test_load_test_accepts_valid_catalogs
    assert_equal(true, validator.load_test([fixture("en.json"), fixture("fr.json")]))
  end

  def test_schema_accepts_catalog_metadata_and_validation_config
    metadata = File.join(FIXTURE_ROOT, "metadata.json")
    validation = File.join(FIXTURE_ROOT, "validation.json")
    File.open(metadata, "wb") { |file| file.write("{\"battle.wild_appeared\":{\"description\":\"Battle intro\"}}") }
    File.open(validation, "wb") { |file| file.write("{\"source_locale\":\"en\",\"locales\":[\"en\",\"fr\"],\"control_codes\":\"error\"}") }

    assert_equal(true, validator.schema("catalog", fixture("en.json")))
    assert_equal(true, validator.schema("metadata", metadata))
    assert_equal(true, validator.schema("validation", validation))
  ensure
    File.delete(metadata) if metadata && File.exist?(metadata)
    File.delete(validation) if validation && File.exist?(validation)
  end

  def test_validate_reports_missing_keys
    instance = validator

    assert_equal(false, instance.validate(fixture("en.json"), [fixture("fr_missing.json")]))
    assert(instance.errors.join("\n").index("missing key battle.colored"))
  end

  def test_validate_reports_placeholder_mismatch
    instance = validator

    assert_equal(false, instance.validate(fixture("en.json"), [fixture("fr_placeholder_bad.json")]))
    assert(instance.errors.join("\n").index("placeholder mismatch battle.wild_appeared"))
  end

  def test_validate_reports_control_code_mismatch
    instance = validator

    assert_equal(false, instance.validate(fixture("en.json"), [fixture("fr_control_bad.json")]))
    assert(instance.errors.join("\n").index("control-code mismatch battle.colored"))
  end

  def test_validate_human_mode_reports_plain_language_errors
    instance = validator

    assert_equal(false, instance.validate(fixture("en.json"), [fixture("fr_missing.json")], true))
    message = instance.errors.join("\n")
    assert(message.index("still needs a translation"))
    assert(message.index("English:"))
  end

  def test_validate_human_mode_reports_placeholder_guidance
    instance = validator

    assert_equal(false, instance.validate(fixture("en.json"), [fixture("fr_placeholder_bad.json")], true))
    message = instance.errors.join("\n")
    assert(message.index("keep the same {placeholders}"))
    assert(message.index("{pokemon}"))
  end

  def test_report_groups_validation_errors
    instance = validator
    instance.validate(fixture("en.json"), [fixture("fr_missing.json")])
    report = instance.report

    assert_equal(false, report["ok"])
    assert_equal(1, report["groups"]["missing_key"])
    assert(report["errors"][0].index("missing key"))
  end
end
