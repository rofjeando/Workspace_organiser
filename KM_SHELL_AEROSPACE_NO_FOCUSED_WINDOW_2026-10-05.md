# KM memo — AeroSpace reports no focused window (2026-10-05)

## Problem

"WORKSP_Move Window to workspace v1.1" (hot keys ⌥⇧A, ⌥⇧N, ⌥⇧K, ...) was cancelled
intermittently at its first action:

```
2026-10-05 10:05:44 Action 400017432 failed: Task failed with status 1
Task failed with status 1. Macro "WORKSP_Move Window to workspace v1.1" cancelled
(while executing Execute "worksp_capture_focused_window.sh" Shell Script).
```

The same hot keys succeeded at 09:49–09:50, and the script returned 0 when run
from a terminal, including under `env -i` (KM-like empty environment).

## Why

`/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/Workspace_organiser/implementation/shell_scripts/worksp_capture_focused_window.sh`
exits 1 when `aerospace list-windows --focused` returns nothing. AeroSpace has no
focused window when focus is on something it does not manage (an empty workspace —
D, O, S were empty — the Finder desktop, KM or system panels) or for a moment after
an app/workspace switch. The old script discarded AeroSpace's stderr, so which case
applied at 10:05 was not established.

## Fix (commit a3b2920)

- Query focus up to 5 times, 0.15 s apart; accept only a numeric window id.
- On failure, print the frontmost process (System Events), the focused workspace and
  AeroSpace's raw output, plus "click the window, then press the hot key again".
  The action's DisplayKind is Window, so this appears in the KM result window.

No macro change was needed — the action calls the script file by path.

## Open question

If it fails again, the result window now names the frontmost app. If it is always
the same app (or an empty workspace), consider handling that case explicitly, e.g.
falling back to the frontmost app's window via
`aerospace list-windows --workspace focused --app-bundle-id <id>`.

## Knowledge base

`/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/ProjectTemplate/docs/shell_script_guide.md`
entry 2026-10-05.
