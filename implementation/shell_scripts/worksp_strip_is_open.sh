#!/bin/bash
# Prints 1 when the [WORKSP] Strip window is open, nothing otherwise (System Events is the ground truth).
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
n=$(osascript -e 'tell application "System Events" to count (every window of process "Keyboard Maestro Engine" whose name is "WORKSP Strip")' 2>/dev/null)
[ "${n:-0}" -gt 0 ] && echo 1
exit 0
