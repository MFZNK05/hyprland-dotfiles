#!/usr/bin/env bash
# General screenshot helper (grim + slurp).
# Saves a PNG to ~/Pictures/Screenshots AND copies it to the clipboard.
#   screenshot.sh region   -> drag-select an area with the mouse (default)
#   screenshot.sh full     -> capture the entire screen
# Bound in hyprland.conf:  PrtSc = region,  Super+PrtSc = full.
notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a Screenshot "$@"; }

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

case "${1:-region}" in
    full)
        grim "$file" || { notify "Screenshot failed"; exit 1; }
        ;;
    region | *)
        geom="$(slurp 2>/dev/null)" || exit 0   # Esc / right-click cancels -> do nothing
        [ -z "$geom" ] && exit 0
        grim -g "$geom" "$file" || { notify "Screenshot failed"; exit 1; }
        ;;
esac

wl-copy -t image/png < "$file"
notify "Screenshot saved" "$file"
