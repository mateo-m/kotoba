require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))
require "fileutils"

tool_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "tools"))
$LOAD_PATH.unshift(tool_path) unless $LOAD_PATH.include?(tool_path)
require "integration_release"

class IntegrationReleaseTest < KotobaTestCase
  def kotoba_version
    path = File.expand_path(File.join(File.dirname(__FILE__), "..", "kotoba", "VERSION"))
    File.read(path).strip
  end

  def test_version_reads_kotoba_version_file
    assert_equal(kotoba_version, KotobaTools::IntegrationRelease.version)
  end

  def test_full_adapter_matrix_excludes_blocked_adapter
    names = KotobaTools::IntegrationRelease.target_names

    assert_equal(8, names.length)
    assert(names.include?("bare_rgss"))
    assert(names.include?("essentials_bes"))
    assert(names.include?("essentials_v19"))
    assert(names.include?("essentials_v20"))
    assert(!names.include?("essentials_v19_v20"))
    assert(!names.include?("blocked_adapter"))
  end

  def test_package_lists_runtime_adapter_samples_and_manifest_files
    files = KotobaTools::IntegrationRelease.package_relative_files("essentials_v18")

    assert(files.include?("kotoba/core.rb"))
    assert(files.include?("kotoba/VERSION"))
    assert(files.include?("kotoba/adapters/essentials_v18.rb"))
    assert(files.include?("kotoba/adapters/essentials_base.rb"))
    assert(files.include?("kotoba/samples/pokemon_essentials/en.json"))
    assert(files.include?("kotoba/boot.rb"))
    assert(files.include?("kotoba/samples/script_editor/essentials_smoke_test.rb"))
    assert(files.include?("INSTALL.md"))
    assert(files.include?("MANIFEST.json"))
    assert(!files.include?("adapters/essentials_v18.rb"))
    assert(!files.include?("examples/boot_kotoba.rb"))
  end

  def test_manifest_includes_version_adapter_and_files
    manifest = KotobaTools::IntegrationRelease.manifest("bare_rgss")

    assert_equal(kotoba_version, manifest["kotoba_version"])
    assert_equal("bare_rgss", manifest["adapter"])
    assert(manifest["docs_install_url"].index("/essential/installation"))
    assert(manifest["files"].include?("kotoba/adapters/bare_rgss.rb"))
  end

  def test_install_markdown_links_to_online_guide
    text = KotobaTools::IntegrationRelease.install_markdown("essentials_v20")

    assert(text.index("https://mateo-m.github.io/kotoba/essential/installation"))
    assert(text.index("essentials_v20"))
    assert(!text.index("## Troubleshooting"))
  end

  def test_boot_ruby_targets_requested_adapter
    boot = KotobaTools::IntegrationRelease.boot_ruby("essentials_v20")

    assert(boot.index("essentials_v20"))
    assert(boot.index('Kotoba.use_adapter("essentials_v20"'))
  end

  def test_stage_package_writes_install_boot_and_manifest
    output = File.join(File.dirname(__FILE__), "tmp_integration_release")
    staging = File.join(output, "stage-bare")
    files = KotobaTools::IntegrationRelease.stage_package(staging, "bare_rgss")

    assert(File.exist?(File.join(staging, "INSTALL.md")))
    assert(File.exist?(File.join(staging, "MANIFEST.json")))
    assert(File.exist?(File.join(staging, "kotoba", "boot.rb")))
    assert(File.exist?(File.join(staging, "kotoba", "samples", "script_editor", "load_only.rb")))
    assert(File.exist?(File.join(staging, "kotoba", "core.rb")))
    assert(files.include?("kotoba/boot.rb"))
    assert(!File.exist?(File.join(staging, "adapters")))
  ensure
    FileUtils.rm_rf(output) if output
  end

  def test_build_zip_creates_archive_when_zip_command_exists
    return unless system("which zip > /dev/null 2>&1")

    output = File.join(File.dirname(__FILE__), "tmp_integration_zip")
    path = KotobaTools::IntegrationRelease.build_zip(output, "bare_rgss")

    assert(File.exist?(path))
    listing = `unzip -l #{path.shellescape}`
    assert(listing.index("kotoba/core.rb"))
    assert(!listing.index(".staging"))
  ensure
    FileUtils.rm_rf(output) if output
  end
end
