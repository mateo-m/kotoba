# Third-Party Adapters

Adapters connect `Kotoba` to a game engine, starter kit, plugin, or project convention. They should stay thin: the runtime owns locale fallback, catalog loading, message parsing, and message evaluation; adapters own integration details.

## Adapter Contract

An adapter is any object that responds to:

```ruby
install(options)
```

Register it by name:

```ruby
Kotoba.register_adapter("my_engine", Kotoba::Adapters::MyEngine)
```

Install it later:

```ruby
Kotoba.use_adapter("my_engine", {"load" => true})
```

`use_adapter` looks up the registered adapter and calls `install(options || {})`.

## Complete Minimal Adapter

Create `adapters/my_engine.rb`:

```ruby
require File.join(File.dirname(__FILE__), "registry")

module Kotoba
  module Adapters
    module MyEngine
      def self.install(options)
        paths = options["catalog_paths"] || options[:catalog_paths]
        if paths
          Kotoba.configure do |config|
            config.catalog_paths = paths
          end
        end
        Kotoba.load! if options["load"] || options[:load]
        install_global_helper if options["install_global"] || options[:install_global]
        true
      end

      def self.translate_text(text, variables)
        if text.to_s[0, 7] == "kotoba:"
          return Kotoba.t(text.to_s[7, text.to_s.length - 7], variables || {})
        end
        text
      end

      def self.install_global_helper
        return if Object.method_defined?(:_MY_KOTOBA)
        Object.class_eval do
          def _MY_KOTOBA(key, variables = nil, options = nil)
            Kotoba.t(key, variables || {}, options || {})
          end
        end
      end
    end
  end
end

Kotoba.register_adapter("my_engine", Kotoba::Adapters::MyEngine)
```

Use string and symbol option keys because RPG Maker scripts and external Ruby code often mix both styles.

## Example Usage

```ruby
require_relative "kotoba/core"
require_relative "adapters/my_engine"

Kotoba.use_adapter("my_engine", {
  "catalog_paths" => {
    "en" => ["Locales/en.json"]
  },
  "load" => true,
  "install_global" => true
})

_MY_KOTOBA("menu.save")
```

## Source-Text Bridge Example

Legacy engines often translate source English:

```ruby
_INTL("A wild {1} appeared!", pokemon_name)
```

Use a catalog namespace to map source text to stable keys:

```json
{
  "source_text": {
    "A wild {1} appeared!": "battle.wild_appeared"
  },
  "battle": {
    "wild_appeared": "A wild {pokemon} appeared!"
  }
}
```

Then bridge positional variables:

```ruby
def self.intl(source_text, *args)
  key = Kotoba.t("source_text." + source_text.to_s, nil, {"default" => ""})
  return source_text if key == ""
  Kotoba.t(key, {"pokemon" => args[0], "arg1" => args[0]})
end
```

Source-text bridges are migration tools. New code should call stable keys directly.

## Test Pattern

Put tests under `test/compatibility/`:

```ruby
require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper"))

adapter_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "adapters"))
$LOAD_PATH.unshift(adapter_path) unless $LOAD_PATH.include?(adapter_path)
require "my_engine"

class MyEngineAdapterTest < KotobaTestCase
  FIXTURE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", "fixtures", "my_engine"))

  def test_adapter_loads_catalogs
    Kotoba.use_adapter("my_engine", {
      "catalog_paths" => {"en" => [File.join(FIXTURE_ROOT, "en.json")]},
      "load" => true
    })

    assert_equal("Save", Kotoba.t("menu.save"))
  end
end
```

## Fixture Policy

Every supported adapter target needs fixtures:

- generated minimal catalog data used by tests
- a `SOURCE` file explaining engine/version provenance
- local path, tag, commit, release date, or other source evidence
- notes that fixtures are not copied full game data

Do not claim support for an engine version without fixtures and acceptance tests.

## What Belongs In An Adapter

Good adapter responsibilities:

- configure catalog paths
- load catalogs on install
- bridge engine-specific markers to `Kotoba.t`
- optionally install global helpers
- expose small data-name helpers for known engine data

Bad adapter responsibilities:

- adding parser features
- changing runtime fallback behavior
- putting Pokemon/PBS/map assumptions into `kotoba/`
- loading large binary assets during unit tests
- silently swallowing install failures

## Verification

Run:

```sh
bin/ruby18 bin/lint
```

For core adapter changes, also run the cross-version Docker matrix in [Compatibility](/reference/compatibility).
