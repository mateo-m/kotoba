# Placeholders and special text

Reference: `{placeholders}`, Essentials `{1}`/`{2}`, color codes, plural and select lines.

Edit the translation column in a spreadsheet.

Spreadsheet rules: [For translators](/translators/). Developer syntax: [Message syntax](/essential/message-syntax).

---

## What is a placeholder?

Text in curly braces that the game replaces when the line is shown. Do not delete it or swap it for a fixed word (e.g. `Pikachu` instead of `{pokemon}`).

| English | Your translation | On screen (example) |
| --- | --- | --- |
| `A wild {pokemon} appeared!` | `¡Un {pokemon} salvaje apareció!` | `¡Un Pikachu salvaje apareció!` |
| `Hello, {name}!` | `Bonjour, {name} !` | `Bonjour, Ari !` |
| `You have {count} coins.` | `Tienes {count} monedas.` | `Tienes 42 monedas.` |

The game supplies `Pikachu`, `Ari`, or `42`. You write the words around the placeholder.

---

## Can I move `{1}` and `{2}`?

Pokemon Essentials uses numbered slots in English:

```text
A wild {1} appeared!
{1} used {2}!
```

### Default: keep every placeholder

| English | Good | Bad |
| --- | --- | --- |
| `A wild {1} appeared!` | `¡Un {1} salvaje apareció!` | `¡Un Pikachu salvaje apareció!` |
| `{1} used {2}!` | `¡{1} usó {2}!` | `¡Pikachu usó Impactrueno!` |

### Different word order

You may reorder `{1}`, `{2}`, etc. if:

1. Every number appears exactly once (`{1}` stays `{1}`).
2. You do not remove or rename placeholders.
3. Ask the developer when unsure. They can validate before ship.

| English | Spanish (reordered) | On screen |
| --- | --- | --- |
| `{1} gave {2} to {3}` | `{1} le dio {2} a {3}` | `Misty le dio una Potion a Ash` |
| `A wild {1} appeared!` | `¡Apareció un {1} salvaje!` | `¡Apareció un Pikachu salvaje!` |

Named placeholders (`{pokemon}`, `{name}`) work the same.

---

## Color and control codes

RPG Maker color codes start with `\c[` and end with `\c[0]` (or another number). Copy them exactly.

| English | Good | Bad |
| --- | --- | --- |
| `\c[2]Careful!\c[0]` | `\c[2]¡Cuidado!\c[0]` | `¡Cuidado!` (codes removed) |

Keep `\n`, `\|`, etc. unless the developer says otherwise.

---

## Plural lines (`{count, plural, …}`)

Some English rows change wording by count:

```text
{count, plural, =0 {No items} one {# item} other {# items}}
```

1. Keep `{count, plural,` and branch labels (`=0`, `one`, `other`) unless the developer changes them.
2. Translate only the words inside each `{…}` branch.
3. Keep `#` where English has it. It becomes the number in game.

| English branches | Spanish branches | Count | On screen |
| --- | --- | --- | --- |
| `=0 {No items}` / `one {# item}` / `other {# items}` | `=0 {Sin objetos}` / `one {# objeto}` / `other {# objetos}` | 0 | `Sin objetos` |
| (same) | (same) | 1 | `1 objeto` |
| (same) | (same) | 5 | `5 objetos` |

Ask for a note in the notes column if the row is unclear.

---

## Select lines (`{gender, select, …}`)

```text
{gender, select, female {She} male {He} other {They}} used {move}.
```

Translate `She`, `He`, `They`. Keep `{move}`, `female`, `male`, `other`, and the `select` structure unless the developer approves a change.

| Input | On screen (example) |
| --- | --- |
| gender = female, move = Thunderbolt | `She used Thunderbolt.` |

---

## Checklist

- [ ] Only the translation column was edited
- [ ] Every `{placeholder}` from English remains (same spelling, same braces)
- [ ] Every `{1}`, `{2}`, … appears the right number of times
- [ ] Color codes like `\c[2]` and `\c[0]` are unchanged
- [ ] Plural/select skeleton unchanged unless the developer agreed
- [ ] Skipped rows are blank, not deleted
