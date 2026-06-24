# Map event command reference

RPG Maker XP event commands that can carry player-facing text. Kotoba map import coverage.

## Supported

| Code | Name | Notes |
| --- | --- | --- |
| 101 | Show Text | First line block |
| 401 | Show Text (continuation) | Additional lines |
| 102 | Show Choices | Flat strings and nested choice arrays |
| 402 | When | Choice branch labels |
| 108 | Comment | Plain text and `_INTL` / `_ISPRINTF` in comments |
| 408 | Comment More | Continuation comment lines |
| 355 | Script | `_INTL` / `_ISPRINTF` strings |
| 356 | Script (continuation) | `_INTL` / `_ISPRINTF` strings |
| 655 | Script More | `_INTL` / `_ISPRINTF` strings |
| 657 | Script More | `_INTL` / `_ISPRINTF` strings (single-quoted) |

## Deferred

| Code | Name | Reason |
| --- | --- | --- |
| 118 | Label | Developer jump labels, not player text |
| 119 | Call Common Event | Internal event names |
| 204 | Scroll Map | Numeric scroll parameters; occasional strings are map metadata labels |
| 209 | Set Move Route | Text lives in move-route sub-commands (future work) |
| 231 | Show Picture | Asset filenames, not dialogue |
| 509 | Move Command | Move-route payload |
