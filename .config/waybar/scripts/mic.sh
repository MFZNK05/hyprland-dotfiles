#!/usr/bin/env bash
# Microphone status for waybar custom/mic module.
# Reads the DEFAULT source via wpctl and prints icon + percent (or muted).
# Glyphs:  microphone,  microphone-slash (Font Awesome).

out=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)   # "Volume: 1.00" or "Volume: 1.00 [MUTED]"
vol=$(awk '{print $2}' <<<"$out")
pct=$(awk -v v="${vol:-0}" 'BEGIN{printf "%d", v*100}')

if grep -q "MUTED" <<<"$out"; then
    printf ' muted\n'
else
    printf ' %s%%\n' "$pct"
fi
