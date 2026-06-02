#!/usr/bin/env bash
# Clipboard history picker (cliphist + rofi). Bound to Super+Shift+V.
# First entry wipes the whole history; otherwise the chosen item is copied back.
menu() { rofi -dmenu -i -config "$HOME/.config/rofi/menu.rasi" -p "Clipboard"; }
notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a Clipboard "$@"; }

CLEAR=":: Clear clipboard history ::"

sel=$( (printf '%s\n' "$CLEAR"; cliphist list) | menu )
[ -z "$sel" ] && exit 0

if [ "$sel" = "$CLEAR" ]; then
    cliphist wipe && notify "Clipboard history cleared"
    exit 0
fi

printf '%s' "$sel" | cliphist decode | wl-copy
