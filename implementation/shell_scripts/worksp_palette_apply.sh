#!/bin/bash
# Runs the choice made in the [WORKSP] Window Palette. KM variables arrive as env vars:
#   KMVAR_WORKSP_paletteAction  unfloat | flatten | cancelled
#   KMVAR_WORKSP_paletteWs      workspace the list was built for
#   KMVAR_WORKSP_paletteIds     window ids to unfloat, one per line
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:$PATH"

AS=/opt/homebrew/bin/aerospace
[ -x "$AS" ] || AS=$(command -v aerospace) || { echo "aerospace not found"; exit 1; }

action="${KMVAR_WORKSP_paletteAction:-}"
ws="${KMVAR_WORKSP_paletteWs:-}"
ids="${KMVAR_WORKSP_paletteIds:-}"

# Side by side: flatten the workspace tree, then make the container horizontal
# through any tiled window of that workspace (same effect as alt-shift-t).
side_by_side() {
  local anchor="$1"
  if [ -z "$anchor" ]; then
    anchor=$("$AS" list-windows --workspace "$ws" --format '%{window-id} %{window-layout}' |
             awk '$2!="floating" {print $1; exit}')
  fi
  "$AS" flatten-workspace-tree --workspace "$ws" || return 1
  [ -n "$anchor" ] && "$AS" layout --window-id "$anchor" tiles horizontal >/dev/null
  return 0
}

case "$action" in
  unfloat)
    [ -z "$ws" ] && { echo "no workspace given"; exit 1; }
    n=0; last=""
    for id in $ids; do
      case "$id" in ''|*[!0-9]*) continue ;; esac
      "$AS" layout --window-id "$id" tiling >/dev/null && { n=$((n+1)); last="$id"; }
    done
    [ "$n" -eq 0 ] && { echo "nothing unfloated"; exit 0; }
    side_by_side "$last"
    echo "Unfloated $n window(s) on workspace $ws"
    ;;
  flatten)
    [ -z "$ws" ] && { echo "no workspace given"; exit 1; }
    side_by_side ""
    echo "Workspace $ws tiled side by side"
    ;;
  *)
    exit 0 ;;   # cancelled / empty: do nothing
esac
