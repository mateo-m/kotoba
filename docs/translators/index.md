# For translators

You do not need to open JSON files or run commands. Your developer will send a **spreadsheet** (CSV) or a handoff folder.

## What you will receive

| File | What to do |
| --- | --- |
| `spreadsheet.en.csv` | Open in Google Sheets or Excel. Fill the **translation** column. |
| `README.md` in a handoff zip | Short rules from the developer. |

### Spreadsheet columns

| Column | Edit? | Purpose |
| --- | --- | --- |
| `key` | No | Internal ID used by the game (e.g. `battle.wild_appeared`). |
| `english` | No | Source text to translate from. |
| `translation` | **Yes** | Your translated line goes here. |
| `context` | No | Where the line appears (menu, map, Pokemon name, etc.). |
| `notes` | No | Extra guidance from the developer. |

## Rules

1. **Translate only the `translation` column.**
2. **Keep placeholders exactly as they appear in English** — `{pokemon}`, `{name}`, `{count}`, `{1}`, `{2}`, etc.
3. **Keep RPG Maker color codes exactly** — `\c[2]`, `\c[0]`, and similar.
4. Do not add or remove rows. Do not rename keys.
5. Leave `translation` blank if you are not ready for that row yet.

## Placeholders (read this)

Curly braces are **not** optional decoration — the game fills them in when the line is shown.

| English | Good translation | On screen (example) |
| --- | --- | --- |
| `A wild {pokemon} appeared!` | `Un {pokemon} sauvage apparait !` | `Un Pikachu sauvage apparait !` |
| `A wild {1} appeared!` | `¡Un {1} salvaje apareció!` | `¡Un Pikachu salvaje apareció!` |
| `\c[2]Careful!\c[0]` | `\c[2]¡Cuidado!\c[0]` | red “¡Cuidado!” in game |

**Can you move `{1}` and `{2}` for grammar?** Often yes — but every number must still appear exactly once. Ask the developer if unsure.

**Full guide:** [Placeholders and special text](/translators/placeholders) (plural lines, select lines, checklist).

## When you are done

Send the spreadsheet back to the developer. They import it and check that placeholders and color codes still match.

If something is unclear, ask the developer to add a note in the `notes` or `context` column and resend the sheet.

## See also

- [Placeholders and special text](/translators/placeholders) — `{1}`/`{2}`, plural, color codes
- [Spreadsheet handoff](/translators/handoff) — how your developer prepares files
