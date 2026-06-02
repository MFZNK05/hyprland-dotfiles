#!/usr/bin/env bash
# Installs these dotfiles into ~/.config (backs up anything it would overwrite),
# then runs the post-setup steps. Install packages first (see packages.txt).
set -e

DOT="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.config-backup-$STAMP"

echo ":: Backing up existing configs to $BACKUP"
mkdir -p "$BACKUP"
for d in "$DOT"/.config/*/; do
    name="$(basename "$d")"
    [ -e "$HOME/.config/$name" ] && cp -r "$HOME/.config/$name" "$BACKUP/" 2>/dev/null || true
done

echo ":: Copying configs into ~/.config"
cp -r "$DOT/.config/." "$HOME/.config/"

echo ":: Making scripts executable"
chmod +x "$HOME"/.config/hypr/scripts/*.sh "$HOME"/.config/waybar/scripts/*.sh 2>/dev/null || true

echo ":: Linking current wallpaper (lockscreen + swaybg follow this)"
ln -sf "$HOME/.config/hypr/wallpapers/anime_skull.jpg" "$HOME/.config/hypr/.current_wallpaper"

if command -v matugen >/dev/null 2>&1; then
    echo ":: Generating colors from wallpaper with matugen"
    matugen image "$HOME/.config/hypr/wallpapers/anime_skull.jpg" --mode dark --prefer saturation || true
else
    echo "!! matugen not found — install it (see packages.txt), then:"
    echo "   matugen image ~/.config/hypr/wallpapers/anime_skull.jpg --mode dark --prefer saturation"
fi

cat <<'EOF'

Done. Remaining manual steps:
  - Install packages          -> see packages.txt
  - Brightness perms          -> sudo usermod -aG video $USER  (then re-login)
  - Nerd Font + Ubuntu font   -> see packages.txt
  - Log out, pick "Hyprland" at the login screen.
EOF
