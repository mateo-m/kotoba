# For translators

You do not need JSON or RPG Maker. The developer sends a spreadsheet (CSV) or a handoff zip.

## Incoming files

| File | What to do |
| --- | --- |
| `spreadsheet.en.csv` | Open in Google Sheets or Excel. Fill the translation column. |
| `README.md` in a handoff zip | Rules from the developer. |

### Spreadsheet columns

| Column | Edit? | Purpose |
| --- | --- | --- |
| `key` | No | Internal ID (e.g. `battle.wild_appeared`). |
| `english` | No | Source text. |
| `translation` | Yes | Your line. |
| `context` | No | Where it appears (menu, map, etc.). |
| `notes` | No | Developer notes. |

## Rules

1. Edit only the `translation` column.
2. Keep placeholders as in English: `{pokemon}`, `{name}`, `{count}`, `{1}`, `{2}`, etc.
3. Keep RPG Maker color codes: `\c[2]`, `\c[0]`, and similar.
4. Do not add, remove, or rename rows.
5. Leave `translation` blank if you are not done with that row.

## Placeholders

Curly braces are filled in by the game at show time.

| English | Good translation | On screen (example) |
| --- | --- | --- |
| `A wild {pokemon} appeared!` | `Un {pokemon} sauvage apparait !` | `Un Pikachu sauvage apparait !` |
| `A wild {1} appeared!` | `¡Un {1} salvaje apareció!` | `¡Un Pikachu salvaje apareció!` |
| `\c[2]Careful!\c[0]` | `\c[2]¡Cuidado!\c[0]` | red “¡Cuidado!” in game |

You can reorder `{1}` and `{2}` for grammar if each number still appears once. Ask the developer if unsure.

Details: [Placeholders](/translators/placeholders).

## Hand back

Send the spreadsheet back. The developer imports it and checks placeholders and color codes.

Unclear strings? Ask for a note in `notes` or `context` and a new sheet.
