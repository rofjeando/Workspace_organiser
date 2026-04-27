#!/bin/bash
# aerospace_move_interactive.sh
# Shows a list of workspaces and moves the focused window to the chosen one.
# Designed to be called from a KM "Execute Shell Script" action.
# KM must have "Display Results" or the script returns the chosen workspace.
#
# Easier alternative: use KM's native "Prompt for Input" action with a list,
# set the result to variable WorkspaceLetter, then call aerospace_move.sh.
# See the workspace legend below for the prompt list items.
#
# Workspace legend — KM Prompt with List items (uses __ separator):
#   KM returns the letter before __ and displays the full description.
#
#   N__Notes         (Skim, DEVONthink, Antidote, Typora)
#   A__Automation    (KM, WezTerm, opcode, Windsurf, Comet, ScriptDebugger)
#   P__Presentation  (Keynote, Affinity Designer)
#   S__Session-zoom  (Zoom → Elgato screen)
#   B__Booking       (Mail, BusyCal, BBEdit)
#   R__Reading       (Safari)
#   O__sOund         (Audio Hijack, Audirvana)
#   D__Desktop       (MacBook built-in screen)

AEROSPACE=/opt/homebrew/bin/aerospace

# Accept workspace letter from:
#   $1           — command-line argument (e.g. script.sh R)
#   $WorkspaceLetter — KM environment variable (KM exports all variables to the shell
#                      when running a script file; no argument needed in that mode)
# Strip all whitespace to guard against accidental spaces (e.g. "S " from "S __…" in KM list)
WORKSPACE=$(echo "${1:-$WorkspaceLetter}" | tr -d '[:space:]')

if [ -z "$WORKSPACE" ]; then
    echo "No workspace specified. Pass as argument or set KM variable WorkspaceLetter." >&2
    exit 1
fi

"$AEROSPACE" move-node-to-workspace "$WORKSPACE"
"$AEROSPACE" workspace "$WORKSPACE"
