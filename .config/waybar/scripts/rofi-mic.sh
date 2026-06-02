#!/usr/bin/env bash
# Input (microphone) menu: pick input device, mute, volume, pavucontrol.
THEME="$HOME/.config/rofi/menu.rasi"
menu() { rofi -dmenu -i -config "$THEME" "$@"; }

vol=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
pct=$(awk -v v="$(printf '%s' "$vol" | awk '{print $2}')" 'BEGIN{printf "%d", v*100}')
mut=""; printf '%s' "$vol" | grep -q MUTED && mut=" · muted"

# entries: "ID<TAB>NAME" for each source (exclude camera/V4L2 video nodes)
entries=$(wpctl status | sed -n '/Sources:/,/Filters:/p' | sed 's/[│├─└*]//g' \
    | grep -E '^[[:space:]]*[0-9]+\.' | grep -viE 'v4l2|camera' \
    | sed -E 's/[[:space:]]*\[vol:[^]]*\]//' \
    | sed -E 's/^[[:space:]]*([0-9]+)\.[[:space:]]*(.+[^[:space:]])[[:space:]]*$/\1\t\2/')

names=$(printf '%s\n' "$entries" | cut -f2-)

choice=$(printf '%s\n%s\n' "$names" $'Toggle mute\nVolume +5%\nVolume -5%\nOpen pavucontrol' | menu -p "Mic ${pct}%${mut}")
[ -z "$choice" ] && exit 0
case "$choice" in
  "Toggle mute")      wpctl set-mute   @DEFAULT_AUDIO_SOURCE@ toggle ;;
  "Volume +5%")       wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SOURCE@ 5%+ ;;
  "Volume -5%")       wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%- ;;
  "Open pavucontrol") setsid -f pavucontrol >/dev/null 2>&1 ;;
  *) id=$(printf '%s\n' "$entries" | awk -F'\t' -v n="$choice" '$2==n{print $1; exit}')
     [ -n "$id" ] && wpctl set-default "$id" ;;
esac
