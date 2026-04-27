#!/bin/bash
# aerospace_move.sh
# Moves the focused window to a workspace, then switches to it.
#
# Accepts the workspace letter in two ways — use whichever suits your KM macro:
#
#   A) As a command-line argument:
#      /bin/bash aerospace_move.sh P
#
#   B) As a KM variable substituted inline:
#      /bin/bash aerospace_move.sh %Variable%WorkspaceLetter%
#
# Both result in the same behaviour.

AEROSPACE=/opt/homebrew/bin/aerospace
WORKSPACE="${1}"

if [ -z "$WORKSPACE" ]; then
    echo "Error: workspace letter required. Example: aerospace_move.sh P" >&2
    exit 1
fi

"$AEROSPACE" move-node-to-workspace "$WORKSPACE"
"$AEROSPACE" workspace "$WORKSPACE"
