# KM: WORKSP_Move Window to workspace — review and v1.1 fixes (2026-10-02)

Macro: `WORKSP_Move Window to workspace v1.1` (1FEFBA96-FE08-43C6-84A0-8352B99DB063), group `__ [WORKSP]` (3B0B9AEB-510C-4A2D-8939-9B794FFAD7FB).
Export: `/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/Workspace_organiser/implementation/WORKSP_Move Window to workspace v1.1.kmmacros`

Purpose: ⌥⇧ + A/B/D/K/N/O/P/R/S/U moves the focused window to that AeroSpace workspace, after a Stay / Follow prompt. Replaces the `alt-shift-<letter>` bindings now commented out in `aerospace.toml`.

## Problems found

### 1. Window titles containing `"` broke the variable hand-off
- **Why:** the shell action expanded `$WIN_TITLE` inside an unquoted heredoc, i.e. inside the AppleScript source. A `"` in the title ends the AppleScript string and the script fails to compile, so `WORKSP_windowID` etc. stay empty.
- **Fix:** values passed as argv to a quoted heredoc (`osascript - "$A" "$B" <<'APPLESCRIPT'` + `on run argv`). Tested with `He said "hi" \ $HOME`.

### 2. "Stay /S" button contained an invisible THIN SPACE (U+2009)
- **Why:** KM strips only the `/S` shortcut suffix, so `%PromptButton%` was `Stay` + U+2009. This is why the macro needed two Trim Whitespace filters plus a zsh `trim()`.
- **Fix:** buttons renamed `Stay/S`, `Follow/F`, `Cancel/.`; all trims removed. Found with Python `b['Button'].encode('unicode_escape')`.

### 3. Stale destination on an unmapped trigger
- **Why:** the Switch on `%TriggerValue%` had no Otherwise case and `WORKSP_destWorkspace` was never reset, so an unmatched trigger would reuse the previous run's workspace.
- **Fix:** per-run variables reset at the start; Otherwise case shows a notification and cancels just this macro.

### 4. Errors were invisible
- **Why:** the final shell action had DisplayKind None, so "Missing variable(s)" only appeared as "Task failed with status 1" in Engine.log.
- **Fix:** both shell actions display results in a window (they print nothing on success).

## v1.1 changes

| Action | Before | After |
|---|---|---|
| 3 disabled test shell scripts, disabled Display Text, empty disabled If | present | removed |
| Reset variables | windowTitle, windowID | + sourceWorkspace, destWorkspace, moveMode |
| Switch on `WORKSP_trigger` | 10 cases | + Otherwise → Notification + Cancel Just This Macro |
| Capture focused window | inline script, 4 aerospace calls | `implementation/shell_scripts/worksp_capture_focused_window.sh`, 1 call |
| Prompt for User Input | `Stay /S` (U+2009), title "Untitled" | `Stay/S`, title "Move window to workspace" |
| Trim Whitespace filters + `trim()` | 3 trims | removed |
| Move window | inline script, DisplayKind None | `implementation/shell_scripts/worksp_move_window.sh`, DisplayKind Window |

## Side finding: the export "bug"

`[EXM] Export Macros study_FIXEDv2` with OTHER seemed to produce no XML. It was waiting on its Prompt for File panel, which was open but not visible (System Events listed a Keyboard Maestro Engine window "Open"; AeroSpace did not list it). Re-running and choosing the folder worked. Check with:

```
osascript -e 'tell application "System Events" to get name of every window of process "Keyboard Maestro Engine"'
```

Minor: its "Get old file size" step uses `stat ... 2>&1`, so the stat error text appears as "Old size" for new files; `2>/dev/null` would fix it.

## Caveats

- Hot keys use KeyCodes (12 = A on AZERTY), matching the old `alt-shift-q` binding.
- The scripts are referenced by absolute Dropbox path; moving the project breaks the macro.
- The "Mail Colour Palette" `on-window-detected` rule in `aerospace.toml` (uncommitted) never runs: the general KM Engine float rule matches first, and AeroSpace does not see Custom HTML Prompt windows anyway.
