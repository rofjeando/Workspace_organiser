#!/bin/bash
# Feeds the Gather picker: every window AeroSpace tracks, on any monitor, except those already in W.
#   <window-id><TAB><workspace><TAB><app><TAB><title>
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"
AS=/opt/homebrew/bin/aerospace
[ -x "$AS" ] || AS=$(command -v aerospace) || { echo "ERROR	aerospace not found"; exit 0; }
"$AS" list-windows --monitor all \
  --format '%{window-id}%{tab}%{workspace}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{window-title}' 2>/dev/null |
awk -F'\t' '$2!="W" && $3!="com.stairways.keyboardmaestro.engine" { printf "%s\t%s\t%s\t%s\n", $1, $2, $4, $5 }' |
sort -t "$(printf '\t')" -k2,2 -k3,3
exit 0
