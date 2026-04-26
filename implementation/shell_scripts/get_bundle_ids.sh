#!/bin/bash
# get_bundle_ids.sh
# Lists the bundle ID of every running GUI application.
# Use this to find app-id values for AeroSpace on-window-detected rules.
#
# Usage: bash get_bundle_ids.sh
# In Keyboard Maestro: "Execute Shell Script" action, capture output to variable/clipboard.

osascript << 'APPLESCRIPT'
set output to "App Name                       | Bundle ID" & linefeed
set output to output & "-------------------------------|------------------------------------------" & linefeed

tell application "System Events"
    set appList to every application process whose background only is false
    repeat with p in appList
        try
            set appName to name of p
            set appPath to POSIX path of (file of p)
            set bid to do shell script "mdls -name kMDItemCFBundleIdentifier -raw " & quoted form of appPath
            -- Pad app name to 30 chars for alignment
            set padded to appName
            repeat while (count of padded) < 30
                set padded to padded & " "
            end repeat
            set output to output & padded & " | " & bid & linefeed
        on error
            -- Skip processes without a file reference (daemons, etc.)
        end try
    end repeat
end tell

return output
APPLESCRIPT
