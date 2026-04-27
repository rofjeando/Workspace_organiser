#!/bin/bash
# float_half_screen.sh
# Makes the focused window floating and positions it to the LEFT HALF of the LG HDR WQHD screen.
# Run this AFTER the window is already on the target workspace.
#
# LG HDR WQHD resolution: 2560 × 1440
# Left half: x=0, y=0, width=1280, height=1440
# (Adjust LG_ORIGIN_X if the LG is not the leftmost monitor in your arrangement)
#
# In Keyboard Maestro: "Execute Shell Script" action

AEROSPACE=/opt/homebrew/bin/aerospace

# --- Configure these for your monitor layout ---
# Run:  aerospace list-monitors
# Then arrange monitors in System Settings > Displays > Arrange
# and note the top-left pixel coordinate of the LG screen.
# Common setups:
#   LG is main (leftmost):  LG_ORIGIN_X=0
#   LG is to the right of MacBook:  LG_ORIGIN_X=1512  (MacBook width at default scaling)
LG_ORIGIN_X=0
LG_ORIGIN_Y=0
LG_WIDTH=2560
LG_HEIGHT=1440
HALF_WIDTH=$((LG_WIDTH / 2))

# Make the focused window floating
"$AEROSPACE" layout floating

# Give AeroSpace a moment to release the window to the OS
sleep 0.15

# Get the name of the focused app
APP_NAME=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)

if [ -z "$APP_NAME" ]; then
    echo "Could not determine focused app" >&2
    exit 1
fi

# Set the window bounds: left half of LG screen
osascript << APPLESCRIPT
tell application "System Events"
    tell process "$APP_NAME"
        try
            set position of window 1 to {$LG_ORIGIN_X, $LG_ORIGIN_Y}
            set size of window 1 to {$HALF_WIDTH, $LG_HEIGHT}
        on error errMsg
            -- Some apps use a different window model; try via GUI scripting
        end try
    end tell
end tell
APPLESCRIPT
