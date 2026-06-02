#!/usr/bin/env bash
# Wallpaper switcher: pick an image -> set via hyprpaper -> recolor the whole
# rice via matugen (regenerates waybar/rofi/hyprland colors from the wallpaper).
# Usage: wallpaper.sh [/path/to/image]   (no arg = rofi picker from the wallpapers dir)

WALLDIR="$HOME/.config/hypr/wallpapers"
THEME="$HOME/.config/rofi/menu.rasi"
notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a Wallpaper "$@"; }

if [ -n "$1" ] && [ -f "$1" ]; then
    wp="$1"
else
    imgs=$(find "$WALLDIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' 2>/dev/null | sort)
    [ -z "$imgs" ] && { notify "No images in $WALLDIR"; exit 1; }
    sel=$(printf '%s\n' "$imgs" | rofi -dmenu -i -config "$THEME" -p "Wallpaper")
    [ -z "$sel" ] && exit 0
    wp="$WALLDIR/$sel"
fi
[ -f "$wp" ] || { notify "Not found: $wp"; exit 1; }

# Lockscreen follows the wallpaper via this symlink
ln -sf "$wp" "$HOME/.config/hypr/.current_wallpaper"

# Set wallpaper with swaybg: launch the new one, then kill the previous ones (avoids a black flash)
old=$(pgrep -x swaybg)
setsid -f bash -c "swaybg -i '$wp' -m fill >/dev/null 2>&1"
sleep 0.5
for p in $old; do kill "$p" 2>/dev/null; done

# Recolor: matugen regenerates colors + post-hooks reload Hyprland; waybar needs a restart
matugen image "$wp" --mode dark --prefer saturation >/dev/null 2>&1
pkill -x waybar 2>/dev/null; sleep 0.3; setsid -f bash -c 'waybar >/dev/null 2>&1'

notify "Wallpaper set" "$(basename "$wp")"
