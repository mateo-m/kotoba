require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

class MessageEvalTest < RGSSI18nTestCase
  def evaluate(message, variables, locale)
    RGSSI18n::MessageEval.evaluate(RGSSI18n::MessageEval.compile(message), variables, locale)
  end

  def test_interpolates_string_and_symbol_variables
    assert_equal("A wild Pikachu appeared!", evaluate("A wild {pokemon} appeared!", {"pokemon" => "Pikachu"}, "en"))
    assert_equal("A wild Eevee appeared!", evaluate("A wild {pokemon} appeared!", {:pokemon => "Eevee"}, "en"))
  end

  def test_keeps_missing_variables_visible
    assert_equal("Hello, {name}!", evaluate("Hello, {name}!", {}, "en"))
  end

  def test_evaluates_select_messages
    message = "{gender, select, female {She} male {He} other {They}} used {move}."

    assert_equal("She used Thunderbolt.", evaluate(message, {"gender" => "female", "move" => "Thunderbolt"}, "en"))
    assert_equal("They used Surf.", evaluate(message, {"gender" => "unknown", "move" => "Surf"}, "en"))
  end

  def test_evaluates_plural_exact_category_and_hash
    message = "{count, plural, =0 {No items} one {# item} other {# items}}"

    assert_equal("No items", evaluate(message, {"count" => 0}, "en"))
    assert_equal("1 item", evaluate(message, {"count" => 1}, "en"))
    assert_equal("5 items", evaluate(message, {"count" => 5}, "en"))
  end

  def test_uses_locale_plural_rules
    message = "{count, plural, one {# predmet} few {# przedmioty} many {# przedmiotow} other {# przedmiotu}}"

    assert_equal("1 predmet", evaluate(message, {"count" => 1}, "pl"))
    assert_equal("2 przedmioty", evaluate(message, {"count" => 2}, "pl"))
    assert_equal("5 przedmiotow", evaluate(message, {"count" => 5}, "pl"))
  end

  def test_preserves_common_apostrophes_and_escaped_syntax
    message = "Bob's item uses '{count}' and ''quotes''."

    assert_equal("Bob's item uses {count} and 'quotes'.", evaluate(message, {"count" => 3}, "en"))
  end

  def test_requires_other_branch_for_select
    assert_raise(RGSSI18n::MessageParseError) do
      RGSSI18n::MessageEval.compile("{gender, select, female {She}}")
    end
  end

  def test_requires_other_branch_for_plural
    assert_raise(RGSSI18n::MessageParseError) do
      RGSSI18n::MessageEval.compile("{count, plural, one {One}}")
    end
  end
end
