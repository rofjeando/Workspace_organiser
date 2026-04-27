#!/bin/bash
# move_to_workspace.sh
# Moves the currently focused window to a target AeroSpace workspace,
# then switches focus to that workspace.
#
# Usage: bash move_to_workspace.sh <WORKSPACE>
# Examples:
#   bash move_to_workspace.sh P   → move to Presentation (LG)
#   bash move_to_workspace.sh A   → move to Automation (LG)
#   bash move_to_workspace.sh S   → move to Session-zoom (Elgato)
#
# In Keyboard Maestro: "Execute Shell Script" action
#   Shell: /bin/bash
#   Script: bash /path/to/move_to_workspace.sh P
#   (or pass workspace as a KM variable)

AEROSPACE=/opt/homebrew/bin/aerospace
WORKSPACE="${1}"

if [ -z "$WORKSPACE" ]; then
    echo "Error: no workspace specified. Usage: $0 <WORKSPACE>" >&2
    exit 1
fi

# Move the focused window to the target workspace
"$AEROSPACE" move-node-to-workspace "$WORKSPACE"

# Switch focus to that workspace (follows the window)
"$AEROSPACE" workspace "$WORKSPACE"
