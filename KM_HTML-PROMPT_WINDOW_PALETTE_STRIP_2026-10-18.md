# KM memo: WORKSP window palette, button strip, Gather to W (2026-10-18)

## Problem
Floating windows (Obsidian, DeepSeek, etc.) were hard to tile again, and the user wanted:
a checkbox chooser to unfloat several windows, a permanent narrow button strip for
workspace tiling, and a new AeroSpace workspace W ("Work in progress") filled with hand-picked windows.

## What was built
| Piece | File / UID | Status |
|---|---|---|
| Unfloat palette (sync HTML prompt) | macro `WORKSP_Window Palette (unfloat / side by side)` F39F44BF-0355-4166-B3C5-B4F248D3727E | confirmed working by the user |
| Button strip (async HTML prompt) | macro `WORKSP_Strip (permanent button strip)` 3FC8984A-B08D-4953-9DA6-A55F2E1B3452 | imported and exported; behaviour not yet confirmed |
| Strip dispatcher | macro `WORKSP_Strip Action` C2F91351-52B1-4E64-B9BC-FF92FB321ADB (`%TriggerValue%` -> `WORKSP_stripAction`) | not yet confirmed |
| Gather picker (sync HTML prompt) | macro `WORKSP_Gather to W` 783EDAD9-F11C-4785-A029-686BA60DCBC1 | exported 2026-10-18 16:30; not yet confirmed |

All in group `__ [WORKSP]` (3B0B9AEB-510C-4A2D-8939-9B794FFAD7FB). Imports arrive disabled: enable each.

Files in /Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/Workspace_organiser/implementation/:
- `html_prompts/worksp_window_palette.html`, `worksp_strip.html`, `worksp_gather_picker.html`
- `shell_scripts/worksp_unfloat_list.sh` (floating windows of the focused workspace, Finder/Engine/scratchPad flagged keep)
- `shell_scripts/worksp_palette_apply.sh` (unfloat / flatten, env `KMVAR_WORKSP_palette*`)
- `shell_scripts/worksp_strip_action.sh` (sidebyside, stacked, tabs, balance, gotow, back, reload, gather)
- `shell_scripts/worksp_gather_list.sh`, `worksp_strip_is_open.sh`
- `toml_configs/aerospace.toml`: workspace W (persistent, LG monitor), `alt-z` go to W, `alt-shift-z` move window to W (AZERTY key labeled w), root orientation `horizontal`, `alt-shift-t` flatten + side by side.
- `~/.config/sketchybar/sketchybarrc`: item `W: WorkInProgress` (backup `sketchybarrc.bak`).
- `WORKSP_Strip.kmmacros` is the combined import file; per-macro exports sit beside it.
- `shell_scripts/aerospace_unfloat.sh` (Devin's version) is superseded and unused.

## Why these choices
- Script-file shell actions take no arguments, so every value travels as `$KMVAR_...` (KB rule, shell guide 2026-10-06).
- The strip calls macros with `Trigger(UID, value)`; UIDs survive renames (html guide 2026-10-02).
- "Current workspace" = `aerospace list-workspaces --focused`, not `--monitor mouse`, because the mouse is on the strip when a button is clicked.

## Caveats
- A floating HTML prompt ignores the first click after another app had focus (html guide 2026-09-20). If that annoys, rebuild the strip as a native KM palette.
- Strip single-instance check uses System Events `count (every window ... whose name is "WORKSP Strip")`; untested.
- Strip and Gather rely on AeroSpace keeping its last tracked focus while the Engine window is frontmost (shell guide 2026-10-05 supports this); untested.
- `WORKSP_Move Window to workspace v1.0` is disabled (`IsActive` False). An earlier claim that it conflicted with v1.1 was wrong.

## KB entries written from this session
shell_script_guide.md, html_prompt_guide.md and km_xml_import_guide.md in /Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/ProjectTemplate/docs/, all dated 2026-10-18.
