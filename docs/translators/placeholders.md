# Placeholders and special text

You edit the **translation** column in a spreadsheet. This page explains curly braces, Essentials `{1}`/`{2}` slots, color codes, and trickier plural lines — with examples of what appears on screen.

**Spreadsheet rules:** [For translators](/translators/)

**Developer syntax reference:** [Message syntax](/essential/message-syntax)

---

## What is a placeholder?

A placeholder is text in **curly braces** that the game swaps in when the line is shown. **Do not delete it.** **Do not replace it with a fixed word** (like writing `Pikachu` instead of `{pokemon}`).

| English | Your translation | On screen (example) |
| --- | --- | --- |
| `A wild {pokemon} appeared!` | `¡Un {pokemon} salvaje apareció!` | `¡Un Pikachu salvaje apareció!` |
| `Hello, {name}!` | `Bonjour, {name} !` | `Bonjour, Ari !` |
| `You have {count} coins.` | `Tienes {count} monedas.` | `Tienes 42 monedas.` |

The game supplies `Pikachu`, `Ari`, or `42`. Your job is the words **around** the placeholder.

---

## Can I move `{1}` and `{2}`?

**Pokemon Essentials** often uses numbered slots in English:

```text
A wild {1} appeared!
{1} used {2}!
```

### Default rule: keep every placeholder

| English | Good | Bad |
| --- | --- | --- |
| `A wild {1} appeared!` | `¡Un {1} salvaje apareció!` | `¡Un Pikachu salvaje apareció!` |
| `{1} used {2}!` | `¡{1} usó {2}!` | `¡Pikachu usó Impactrueno!` |

### When your language needs a different word order

In some languages the verb and noun order differs from English. You **may reorder `{1}`, `{2}`, etc.** as long as:

1. **Every number still appears exactly once** — `{1}` stays `{1}`, not `{2}`.
2. **You do not remove or rename placeholders.**
3. **You ask the developer** if you are unsure — they can run a check before the translation ships.

| English | Spanish (reordered) | On screen |
| --- | --- | --- |
| `{1} gave {2} to {3}` | `{1} le dio {2} a {3}` | `Misty le dio una Potion a Ash` |
| `A wild {1} appeared!` | `¡Apareció un {1} salvaje!` | `¡Apareció un Pikachu salvaje!` |

Named placeholders (`{pokemon}`, `{name}`) work the same way — you can move them for grammar, but keep the name inside the braces.

---

## Color and control codes

RPG Maker color codes start with `\c[` and end with `\c[0]` (or another number). Copy them **exactly**.

| English | Good | Bad |
| --- | --- | --- |
| `\c[2]Careful!\c[0]` | `\c[2]¡Cuidado!\c[0]` | `¡Cuidado!` (codes removed) |

Other codes (`\n` for a line break, `\|`, etc.) should stay unless the developer tells you otherwise.

---

## Plural lines (`{count, plural, …}`)

Some English rows pick different wording by count:

```text
{count, plural, =0 {No items} one {# item} other {# items}}
```

**What to do:**

1. Keep `{count, plural,` and the branch labels (`=0`, `one`, `other`) as in English unless the developer helps you change them.
2. Translate only the **words inside** each `{…}` branch.
3. Keep `#` where English has it — it becomes the number in game.

| English branches | Spanish branches | Count | On screen |
| --- | --- | --- | --- |
| `=0 {No items}` / `one {# item}` / `other {# items}` | `=0 {Sin objetos}` / `one {# objeto}` / `other {# objetos}` | 0 | `Sin objetos` |
| (same) | (same) | 1 | `1 objeto` |
| (same) | (same) | 5 | `5 objetos` |

If this row looks scary, ask the developer to add a note in the **notes** column.

---

## Select lines (`{gender, select, …}`)

Some lines pick a word based on a value (often gender):

```text
{gender, select, female {She} male {He} other {They}} used {move}.
```

Translate `She`, `He`, `They`, and keep `{move}`. Keep `female`, `male`, `other`, and the `select` structure unless the developer approves a change.

| Input | On screen (example) |
| --- | --- |
| gender = female, move = Thunderbolt | `She used Thunderbolt.` |

---

## Checklist before you send the sheet back

- [ ] Only the **translation** column was edited
- [ ] Every `{placeholder}` from English is still there (same spelling, same braces)
- [ ] Every `{1}`, `{2}`, … appears the right number of times
- [ ] Color codes like `\c[2]` and `\c[0]` are unchanged
- [ ] Plural/select skeleton unchanged unless the developer agreed
- [ ] Rows you skipped are left blank, not deleted

---

## See also

- [For translators](/translators/) — spreadsheet columns and workflow
- [Spreadsheet handoff](/translators/handoff) — what your developer does before sending the file
