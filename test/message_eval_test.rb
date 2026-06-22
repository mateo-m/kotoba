require File.expand_path(File.join(File.dirname(__FILE__), "test_helper"))

class MessageEvalTest < KotobaTestCase
  def evaluate(message, variables, locale)
    Kotoba::MessageEval.evaluate(Kotoba::MessageEval.compile(message), variables, locale)
  end

  def evaluate_with_options(message, variables, locale, options)
    Kotoba::MessageEval.evaluate(Kotoba::MessageEval.compile(message, options), variables, locale, options)
  end

  def test_interpolates_string_and_symbol_variables
    assert_equal("A wild Pikachu appeared!", evaluate("A wild {pokemon} appeared!", {"pokemon" => "Pikachu"}, "en"))
    assert_equal("A wild Eevee appeared!", evaluate("A wild {pokemon} appeared!", {:pokemon => "Eevee"}, "en"))
  end

  def test_plain_messages_compile_to_fast_path
    compiled = Kotoba::MessageEval.compile("Save")

    assert_equal("Save", compiled)
    assert_equal("Save", Kotoba::MessageEval.evaluate(compiled, {}, "en"))
  end

  def test_keeps_missing_variables_visible
    assert_equal("Hello, {name}!", evaluate("Hello, {name}!", {}, "en"))
  end

  def test_missing_variable_policy_can_empty_or_raise
    assert_equal("Hello, !", evaluate_with_options("Hello, {name}!", {}, "en", {"missing_variable_policy" => "empty"}))
    assert_raise(Kotoba::MessageEvaluationError) do
      evaluate_with_options("Hello, {name}!", {}, "en", {"missing_variable_policy" => "error"})
    end
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

  def test_plural_requires_present_integer_variable
    message = "{count, plural, =0 {No items} one {# item} other {# items}}"

    assert_raise(Kotoba::MessageEvaluationError) do
      evaluate(message, {}, "en")
    end

    assert_raise(Kotoba::MessageEvaluationError) do
      evaluate(message, {"count" => "many"}, "en")
    end
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
    assert_raise(Kotoba::MessageParseError) do
      Kotoba::MessageEval.compile("{gender, select, female {She}}")
    end
  end

  def test_requires_other_branch_for_plural
    assert_raise(Kotoba::MessageParseError) do
      Kotoba::MessageEval.compile("{count, plural, one {One}}")
    end
  end

  def test_enforces_message_depth_limit
    assert_raise(Kotoba::MessageParseError) do
      Kotoba::MessageEval.compile(
        "{a, select, x {{b, select, y {ok} other {ok}}} other {ok}}",
        {"max_depth" => 1}
      )
    end
  end

  def test_french_russian_and_portuguese_plural_rules
    assert_equal("0 chose", evaluate("{count, plural, one {# chose} other {# choses}}", {"count" => 0}, "fr"))
    assert_equal("2 stvari", evaluate("{count, plural, one {# stvar} few {# stvari} many {# stvari} other {# stvari}}", {"count" => 2}, "ru"))
    assert_equal("1 item", evaluate("{count, plural, one {# item} other {# items}}", {"count" => 1}, "pt-BR"))
  end

  def test_expanded_plural_rules
    arabic = "{count, plural, zero {zero} one {one} two {two} few {few} many {many} other {other}}"
    assert_equal("zero", evaluate(arabic, {"count" => 0}, "ar"))
    assert_equal("two", evaluate(arabic, {"count" => 2}, "ar"))
    assert_equal("few", evaluate(arabic, {"count" => 7}, "ar"))
    assert_equal("many", evaluate(arabic, {"count" => 42}, "ar"))

    czech = "{count, plural, one {one} few {few} other {other}}"
    assert_equal("few", evaluate(czech, {"count" => 3}, "cs"))

    slovenian = "{count, plural, one {one} two {two} few {few} other {other}}"
    assert_equal("two", evaluate(slovenian, {"count" => 102}, "sl"))

    lithuanian = "{count, plural, one {one} few {few} other {other}}"
    assert_equal("few", evaluate(lithuanian, {"count" => 2}, "lt"))

    latvian = "{count, plural, zero {zero} one {one} other {other}}"
    assert_equal("zero", evaluate(latvian, {"count" => 0}, "lv"))
  end
end
