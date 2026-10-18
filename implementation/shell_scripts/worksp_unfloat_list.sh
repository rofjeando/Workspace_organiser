#!/bin/bash
# Feeds the [WORKSP] Window Palette (Execute Shell Script -> "Display results in variable").
# Prints the floating windows of the workspace visible on the focused workspace.
#   line 1 : WS<TAB><workspace>
#   then   : <window-id><TAB><keep 0|1><TAB><app><TAB><title>
# keep=1 marks windows that the aerospace.toml floats on purpose (Finder, KM Engine,
# Typora scratchPad_): the palette lists them apart and "Unfloat all" skips them.
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

AS=/opt/homebrew/bin/aerospace
[ -x "$AS" ] || AS=$(command -v aerospace) || { echo "ERROR	aerospace not found"; exit 0; }

ws=$("$AS" list-workspaces --focused 2>/dev/null | head -n 1)
[ -z "$ws" ] && { echo "ERROR	AeroSpace did not answer (is it running?)"; exit 0; }

printf 'WS\t%s\n' "$ws"
"$AS" list-windows --workspace "$ws" \
  --format '%{window-id}%{tab}%{window-layout}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{window-title}' 2>/dev/null |
awk -F'\t' '$2=="floating" {
  keep = 0
  if ($3=="com.apple.finder" || $3=="com.stairways.keyboardmaestro.engine") keep = 1
  if ($3=="abnerworks.Typora" && $5 ~ /^scratchPad_/) keep = 1
  printf "%s\t%d\t%s\t%s\n", $1, keep, $4, $5
}'
exit 0
