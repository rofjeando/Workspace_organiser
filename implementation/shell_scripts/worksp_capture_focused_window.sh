#!/bin/zsh
# Called by KM macro "WORKSP_Move Window to workspace" (before the Stay/Follow prompt).
# Stores the focused window in KM variables:
#   WORKSP_windowID, WORKSP_sourceWorkspace, WORKSP_windowTitle ("App | short title")
# One aerospace call so all values describe the same window.

A=/opt/homebrew/bin/aerospace

# Title is last: read puts any remaining "|" from the title into WIN_TITLE.
IFS='|' read -r WIN_ID SRC_WS APP_NAME WIN_TITLE <<< "$($A list-windows --focused \
  --format '%{window-id}|%{workspace}|%{app-name}|%{window-title}' 2>/dev/null)"

if [[ -z "$WIN_ID" || -z "$SRC_WS" ]]; then
  echo "AeroSpace reported no focused window/workspace."
  exit 1
fi

SHORT_TITLE="${WIN_TITLE//$'\r'/ }"
[[ -z "$SHORT_TITLE" ]] && SHORT_TITLE="$APP_NAME"
(( ${#SHORT_TITLE} > 42 )) && SHORT_TITLE="${SHORT_TITLE[1,39]}..."

# Values go in as argv, never spliced into the AppleScript text,
# so quotes/backslashes in window titles cannot break it.
/usr/bin/osascript - "$WIN_ID" "$SRC_WS" "$APP_NAME | $SHORT_TITLE" <<'APPLESCRIPT'
on run argv
  tell application "Keyboard Maestro Engine"
    setvariable "WORKSP_windowID" to item 1 of argv
    setvariable "WORKSP_sourceWorkspace" to item 2 of argv
    setvariable "WORKSP_windowTitle" to item 3 of argv
  end tell
end run
APPLESCRIPT
