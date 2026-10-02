#!/bin/zsh
# Called by KM macro "WORKSP_Move Window to workspace" (after the Stay/Follow prompt).
# Moves window $KMVAR_WORKSP_windowID to workspace $KMVAR_WORKSP_destWorkspace.
#   WORKSP_moveMode = Stay   → move, keep focus on the source workspace
#   WORKSP_moveMode = Follow → move and switch to the destination workspace
# Prints a message (shown by KM) only when something is wrong.

A=/opt/homebrew/bin/aerospace
DEST_WS="${KMVAR_WORKSP_destWorkspace:-}"
WIN_ID="${KMVAR_WORKSP_windowID:-}"
MODE="${KMVAR_WORKSP_moveMode:-}"

if [[ -z "$DEST_WS" || -z "$WIN_ID" || -z "$MODE" ]]; then
  echo "Missing variable(s): MODE=<$MODE> DEST_WS=<$DEST_WS> WIN_ID=<$WIN_ID>"
  exit 1
fi

case "$MODE" in
  Follow) exec "$A" move-node-to-workspace --focus-follows-window --window-id "$WIN_ID" -- "$DEST_WS" ;;
  Stay)   exec "$A" move-node-to-workspace --window-id "$WIN_ID" -- "$DEST_WS" ;;
  *)      echo "Unknown move mode: <$MODE>"; exit 1 ;;
esac
