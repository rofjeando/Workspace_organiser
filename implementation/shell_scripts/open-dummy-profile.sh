#!/bin/bash
# [SDECK] Open any Profile: launch a Stream Deck "dummy" applet so the deck
# switches profile, then put AeroSpace focus back where it was.
#
# The applet takes focus for ~1 s and quits. macOS then hands focus to its own
# most-recently-used app (e.g. Keynote on K), and AeroSpace follows it. This
# script restores the workspace and window that were focused before.
#
# No arguments. Reads $KMVAR_sdeck_dummyAppName (app name without .app).
# For testing from a terminal pass the app name as $1 and run with
# env -u KMVAR_sdeck_dummyAppName.

# KM's Execute Shell Script may run with an empty PATH
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/usr/local/bin"

DUMMY_ROOT="/Users/tsukadjed/Library/CloudStorage/Dropbox/Automation/applications/Dummy Applications/Dummy Applications SDprofiles"
APP_NAME="${1:-$KMVAR_sdeck_dummyAppName}"
APP_PATH="$DUMMY_ROOT/$APP_NAME.app"

if [[ ! -d "$APP_PATH" ]]; then
    echo "ERROR: app not found at $APP_PATH" >&2
    exit 1
fi

# Remember where focus is (empty if AeroSpace has no focused window)
saved_ws="$(aerospace list-workspaces --focused 2>/dev/null)"
saved_wid="$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null | head -1)"

open -a "$APP_PATH" || exit 1

command -v aerospace >/dev/null && [[ -n "$saved_ws" ]] || exit 0

# Wait for the applet to start, then for it to quit (cap about 6 s)
proc="$APP_NAME"
for _ in $(seq 1 12); do
    pgrep -xq "$proc" && break
    sleep 0.1
done
for _ in $(seq 1 24); do
    pgrep -xq "$proc" || break
    sleep 0.2
done
sleep 0.3   # let macOS finish handing focus to the fallback app

aerospace workspace "$saved_ws" >/dev/null 2>&1
if [[ "$saved_wid" =~ ^[0-9]+$ ]]; then
    aerospace focus --window-id "$saved_wid" >/dev/null 2>&1
fi
exit 0
