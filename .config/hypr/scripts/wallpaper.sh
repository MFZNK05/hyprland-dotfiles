#!/usr/bin/env bash
# Wallpaper switcher: pick a live video (mpvpaper) or an image (swaybg).
# Images also recolor via matugen (templates are static Tokyo Night, so colors stay put).
# Usage: wallpaper.sh                  rofi picker: videos from ~/Videos first, then images
#        wallpaper.sh /path/to/file    set that video or image directly
#        wallpaper.sh --restore        login: last pick (live if marked, else image)

WALLDIR="$HOME/.config/hypr/wallpapers"
VIDDIR="$HOME/Videos"
CURRENT="$HOME/.config/hypr/.current_wallpaper"   # last image; hyprlock reads it too
LIVE="$HOME/.config/hypr/.current_live"           # present only while a video is the wallpaper
MPVPAPER="$HOME/.local/bin/mpvpaper"
MPV_OPTS="loop hwdec=vaapi no-audio profile=fast panscan=1.0"   # GPU decode, no sound
THEME="$HOME/.config/rofi/menu.rasi"
LIVE_TAG="▶ "
notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a Wallpaper "$@"; }

is_video() { case "${1,,}" in *.webm | *.mp4 | *.mkv) return 0 ;; *) return 1 ;; esac; }

# Launch the new wallpaper first, then kill the previous ones (avoids a black flash).
# Both kinds are killed so a video never hides a newly picked image, or vice versa.
swap_to() {
    local old
    old=$(pgrep -x swaybg; pgrep -x mpvpaper)
    setsid -f "$@" >/dev/null 2>&1
    sleep 0.5
    for p in $old; do kill "$p" 2>/dev/null; done
}
start_live()  { swap_to "$MPVPAPER" -p -o "$MPV_OPTS" '*' "$1"; }   # -p: pause when covered
start_image() { swap_to swaybg -i "$1" -m fill; }

if [ "$1" = "--restore" ]; then
    if [ -x "$MPVPAPER" ] && [ -e "$LIVE" ]; then start_live "$LIVE"; else start_image "$CURRENT"; fi
    exit 0
fi

if [ -n "$1" ] && [ -f "$1" ]; then
    wp="$1"
else
    vids=""
    [ -x "$MPVPAPER" ] && vids=$(find "$VIDDIR" -maxdepth 1 -type f \( -iname '*.webm' -o -iname '*.mp4' -o -iname '*.mkv' \) -printf "$LIVE_TAG%f\n" 2>/dev/null | sort)
    imgs=$(find "$WALLDIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' 2>/dev/null | sort)
    [ -z "$vids$imgs" ] && { notify "No wallpapers in $VIDDIR or $WALLDIR"; exit 1; }
    sel=$(printf '%s\n%s\n' "$vids" "$imgs" | sed '/^$/d' | rofi -dmenu -i -config "$THEME" -p "Wallpaper")
    [ -z "$sel" ] && exit 0
    case "$sel" in
        "$LIVE_TAG"*) wp="$VIDDIR/${sel#"$LIVE_TAG"}" ;;
        *) wp="$WALLDIR/$sel" ;;
    esac
fi
[ -f "$wp" ] || { notify "Not found: $wp"; exit 1; }

if is_video "$wp"; then
    [ -x "$MPVPAPER" ] || { notify "mpvpaper not installed" "$MPVPAPER"; exit 1; }
    ln -sf "$wp" "$LIVE"
    start_live "$wp"
else
    rm -f "$LIVE"
    ln -sf "$wp" "$CURRENT"   # lockscreen follows the image
    start_image "$wp"
    # Recolor: matugen regenerates colors + post-hooks reload Hyprland; waybar needs a restart
    matugen image "$wp" --mode dark --prefer saturation >/dev/null 2>&1
    pkill -x waybar 2>/dev/null; sleep 0.3; setsid -f bash -c 'waybar >/dev/null 2>&1'
fi

notify "Wallpaper set" "$(basename "$wp")"
