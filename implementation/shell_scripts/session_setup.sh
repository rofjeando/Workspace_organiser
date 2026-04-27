#!/bin/bash
# session_setup.sh
# Sets up the teaching session layout on workspace P (LG HDR WQHD):
#
#   Layer 1 (back)    Affinity Designer 2  — full LG screen
#   Layer 2 (middle)  Keynote              — left half of LG screen
#   Layer 3 (front)   IINA                 — small overlay (bottom-right)
#
# All three windows are floating so AeroSpace does not interfere with their
# positions, and KM / you can freely bring any one to the front.
#
# Usage: bash session_setup.sh
# In KM: Execute Shell Script action, Shell = /bin/bash
#
# ── Calibration ────────────────────────────────────────────────────────────
# Set these to the top-left pixel origin of the LG screen in your macOS
# display arrangement (System Settings → Displays → Arrange).
# Run `aerospace list-monitors` to confirm monitor order.
LG_X=0          # change if LG is not the leftmost monitor
LG_Y=0
LG_W=2560       # LG HDR WQHD physical width
LG_H=1440       # LG HDR WQHD physical height

# Keynote: left half of LG
KN_X=$LG_X
KN_Y=$LG_Y
KN_W=$((LG_W / 2))   # 1280
KN_H=$LG_H            # 1440

# Affinity Designer: full LG screen (sits behind Keynote)
AD_X=$LG_X
AD_Y=$LG_Y
AD_W=$LG_W
AD_H=$LG_H

# IINA: small overlay, bottom-right of LG (adjust to taste)
IINA_W=640
IINA_H=360
IINA_X=$((LG_X + LG_W - IINA_W - 20))   # 20px from right edge
IINA_Y=$((LG_Y + LG_H - IINA_H - 20))   # 20px from bottom edge

# ── Helpers ────────────────────────────────────────────────────────────────
AEROSPACE=/opt/homebrew/bin/aerospace

activate_and_move() {
    local APP_NAME="$1"
    local BUNDLE_ID="$2"

    # Activate the app (brings it to front, makes its window focused)
    osascript -e "tell application \"$APP_NAME\" to activate"
    sleep 0.3   # allow AeroSpace to detect the window if just launched

    # Move the focused window to workspace P
    "$AEROSPACE" move-node-to-workspace P

    # Release it from tiling
    "$AEROSPACE" layout floating
    sleep 0.15
}

position_window() {
    local APP_NAME="$1"
    local X="$2"
    local Y="$3"
    local W="$4"
    local H="$5"

    osascript << APPLESCRIPT
tell application "System Events"
    tell process "$APP_NAME"
        try
            set position of window 1 to {$X, $Y}
            set size of window 1 to {$W, $H}
        end try
    end tell
end tell
APPLESCRIPT
}

# ── Layer 1: Affinity Designer (full screen, will end up at back) ──────────
activate_and_move "Affinity Designer 2" "com.seriflabs.affinitydesigner2"
position_window   "Affinity Designer 2" $AD_X $AD_Y $AD_W $AD_H

# ── Layer 2: Keynote (left half, will sit on top of Affinity) ─────────────
activate_and_move "Keynote" "com.apple.iWork.Keynote"
position_window   "Keynote" $KN_X $KN_Y $KN_W $KN_H

# ── Layer 3: IINA overlay (front, small window) ───────────────────────────
activate_and_move "IINA" "com.colliderli.iina"
position_window   "IINA" $IINA_X $IINA_Y $IINA_W $IINA_H

# ── Switch to workspace P so the LG shows the session layout ──────────────
"$AEROSPACE" workspace P

echo "Session layout ready on workspace P"
