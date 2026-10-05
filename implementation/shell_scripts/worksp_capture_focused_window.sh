#!/bin/zsh
# Called by KM macro "WORKSP_Move Window to workspace" (before the Stay/Follow prompt).
# Stores the focused window in KM variables:
#   WORKSP_windowID, WORKSP_sourceWorkspace, WORKSP_windowTitle ("App | short title")
# One aerospace call so all values describe the same window.

A=/opt/homebrew/bin/aerospace

# Title is last: read puts any remaining "|" from the title into WIN_TITLE.
# Retry briefly: right after an app/workspace switch AeroSpace can report no focus yet.
for attempt in 1 2 3 4 5; do
  OUT=$($A list-windows --focused \
    --format '%{window-id}|%{workspace}|%{app-name}|%{window-title}' 2>&1)
  IFS='|' read -r WIN_ID SRC_WS APP_NAME WIN_TITLE <<< "$OUT"
  [[ "$WIN_ID" == <-> && -n "$SRC_WS" ]] && break
  WIN_ID=""
  sleep 0.15
done

if [[ -z "$WIN_ID" ]]; then
  FRONT=$(/usr/bin/osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)
  echo "AeroSpace sees no focused window (frontmost app: ${FRONT:-?}; workspace: $($A list-workspaces --focused 2>/dev/null))."
  echo "AeroSpace said: $OUT"
  echo "Click the window you want to move, then press the hot key again."
  exit 1
fi

# Safety check: AeroSpace keeps reporting its last-known window when the app in front is
# one it does not track (e.g. Perplexity, ai.perplexity.macv3). Never move that stale window.
FRONT_ID=$(/usr/bin/osascript -e 'tell application "System Events" to get bundle identifier of first process whose frontmost is true' 2>/dev/null)
AERO_ID=$($A list-windows --focused --format '%{app-bundle-id}' 2>/dev/null)
if [[ -n "$FRONT_ID" && "$FRONT_ID" != "$AERO_ID" \
      && "$FRONT_ID" != "com.stairways.keyboardmaestro.engine" ]]; then
  FRONT_NAME=$(/usr/bin/osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)
  echo "Not moved: $FRONT_NAME is in front, but AeroSpace thinks the focused window is"
  echo "\"$APP_NAME | $WIN_TITLE\" (AeroSpace does not track $FRONT_NAME — $FRONT_ID)."
  echo "Fix: quit and reopen $FRONT_NAME, then try again."
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
