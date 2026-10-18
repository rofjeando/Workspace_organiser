#!/bin/bash
# Runs one button of the [WORKSP] Strip. KM variables arrive as env vars:
#   KMVAR_WORKSP_stripAction  sidebyside | stacked | tabs | balance | gotow | back | reload | gather | cancelled
#   KMVAR_WORKSP_gatherIds    window ids for "gather", one per line
# "Current workspace" = AeroSpace's focused workspace. The strip is a KM window AeroSpace does not
# track, so clicking it leaves AeroSpace's focus on the workspace you came from.
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

AS=/opt/homebrew/bin/aerospace
[ -x "$AS" ] || AS=$(command -v aerospace) || { echo "aerospace not found"; exit 1; }

action="${KMVAR_WORKSP_stripAction:-}"
ids="${KMVAR_WORKSP_gatherIds:-}"
ws=$("$AS" list-workspaces --focused 2>/dev/null | head -n 1)

# First tiled window of a workspace (a layout command needs a tiled window to address).
tiled_anchor() {
  "$AS" list-windows --workspace "$1" --format '%{window-id} %{window-layout}' 2>/dev/null |
    awk '$2!="floating" {print $1; exit}'
}

# Flatten the workspace tree, then set the root orientation through a tiled window.
reshape() {   # $1 workspace  $2.. layout words
  local w="$1" anchor; shift
  anchor=$(tiled_anchor "$w")
  [ -z "$anchor" ] && { echo "No tiled window on $w"; return 0; }
  "$AS" flatten-workspace-tree --workspace "$w" >/dev/null
  "$AS" layout --window-id "$anchor" "$@" >/dev/null
  echo "Workspace $w: $*"
}

case "$action" in
  sidebyside) [ -z "$ws" ] && exit 1; reshape "$ws" tiles horizontal ;;
  stacked)    [ -z "$ws" ] && exit 1; reshape "$ws" tiles vertical ;;
  tabs)       [ -z "$ws" ] && exit 1; reshape "$ws" accordion horizontal ;;
  balance)    [ -z "$ws" ] && exit 1; "$AS" balance-sizes --workspace "$ws" >/dev/null; echo "Workspace $ws balanced" ;;
  gotow)      "$AS" workspace W >/dev/null; echo "Workspace W" ;;
  back)       "$AS" workspace-back-and-forth >/dev/null ;;
  reload)     "$AS" reload-config && echo "AeroSpace config reloaded" ;;
  gather)
    n=0
    for id in $ids; do
      case "$id" in ''|*[!0-9]*) continue ;; esac
      "$AS" move-node-to-workspace --window-id "$id" W >/dev/null 2>&1 && n=$((n+1))
    done
    [ "$n" -eq 0 ] && { echo "Nothing gathered"; exit 0; }
    "$AS" workspace W >/dev/null
    reshape W tiles horizontal >/dev/null
    echo "Gathered $n window(s) in W"
    ;;
  *) exit 0 ;;   # cancelled / empty
esac
