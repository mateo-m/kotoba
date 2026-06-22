require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

class JSONParserTest < KotobaTestCase
  def test_parses_strict_json_values
    parsed = Kotoba::JSON.parse(%({"name":"Potion","count":3,"enabled":true,"tags":["item",null]}))

    assert_equal("Potion", parsed["name"])
    assert_equal(3, parsed["count"])
    assert_equal(true, parsed["enabled"])
    assert_equal(["item", nil], parsed["tags"])
  end

  def test_strips_utf8_bom
    parsed = Kotoba::JSON.parse("\357\273\277{\"ok\":true}")

    assert_equal(true, parsed["ok"])
  end

  def test_parses_unicode_escapes
    parsed = Kotoba::JSON.parse(%({"letter":"\\u0041","face":"\\uD83D\\uDE00"}))

    assert_equal("A", parsed["letter"])
    assert_equal([0xF0, 0x9F, 0x98, 0x80], parsed["face"].unpack("C*"))
  end

  def test_rejects_trailing_commas
    assert_raise(Kotoba::JSONParseError) do
      Kotoba::JSON.parse(%({"name":"Potion",}))
    end
  end

  def test_rejects_leading_zero_numbers
    assert_raise(Kotoba::JSONParseError) do
      Kotoba::JSON.parse(%({"count":01}))
    end
  end

  def test_rejects_unescaped_control_characters
    assert_raise(Kotoba::JSONParseError) do
      Kotoba::JSON.parse("{\"bad\":\"line\nbreak\"}")
    end
  end

  def test_enforces_depth_limit
    assert_raise(Kotoba::JSONParseError) do
      Kotoba::JSON.parse(%({"a":{"b":{"c":1}}}), {"max_depth" => 2})
    end
  end

  def test_can_reject_duplicate_object_keys
    assert_raise(Kotoba::JSONParseError) do
      Kotoba::JSON.parse(%({"menu":{"save":"Save","save":"Store"}}), {"duplicate_keys" => "error"})
    end
  end
end
