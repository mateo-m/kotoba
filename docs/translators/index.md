# For translators

You do not need to open JSON files or run commands. Your developer will send a **spreadsheet** (CSV) or a handoff folder.

## What you will receive

| File | What to do |
| --- | --- |
| `spreadsheet.en.csv` | Open in Google Sheets or Excel. Fill the **translation** column. |
| `README.md` in a handoff zip | Short rules from the developer. |

Columns in the spreadsheet:

| Column | Edit? | Purpose |
| --- | --- | --- |
| `key` | No | Internal ID used by the game. |
| `english` | No | Source text to translate from. |
| `translation` | **Yes** | Your translated line goes here. |
| `context` | No | Where the line appears (menu, map, Pokemon name, etc.). |
| `notes` | No | Extra guidance from the developer. |

## Rules

1. **Translate only the `translation` column.**
2. **Keep placeholders exactly as they appear in English**, such as `{pokemon}`, `{name}`, or `{count}`.
3. **Keep RPG Maker color codes exactly**, such as `\c[2]` and `\c[0]`.
4. If English uses `{1}` or `{2}` (common in Pokemon Essentials), keep the same numbers in the same places.
5. Leave a row blank in `translation` if you are not ready to translate it yet.
6. Do not add or remove rows. Do not rename keys.

## Examples

| english | Good translation | Bad translation |
| --- | --- | --- |
| `A wild {pokemon} appeared!` | `Un {pokemon} sauvage apparait !` | `Un Pikachu sauvage apparait !` (removed `{pokemon}`) |
| `\c[2]Careful!\c[0]` | `\c[2]Attention !\c[0]` | `Attention !` (removed color codes) |
| `You have {count} items.` | `Tu as {count} objets.` | `Tu as 2 objets.` (replaced `{count}` with a number) |

## When you are done

Send the spreadsheet back to the developer. They will import it and check that placeholders and color codes still match.

If something is unclear, ask the developer to add a note in the `notes` or `context` column and resend the sheet.

## See also

- [Spreadsheet handoff for developers](/translators/handoff) — how your developer prepares files
