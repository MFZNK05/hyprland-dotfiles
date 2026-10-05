# Hyprland Dotfiles

My Hyprland rice on **Ubuntu 26.04** (Wayland) — a static Tokyo Night (Night) theme,
with a waybar control center, rofi menus, lock/idle/power, and clipboard history.

> Built piece-by-piece and adapted to a native (apt-based, non-Nix) Ubuntu system.
> Inspired by [ML4W](https://github.com/mylinuxforwork/dotfiles) (theming) and
> [notusknot](https://github.com/notusknot/dotfiles-nix) (ergonomics).

## Stack

| Role | Tool |
|------|------|
| Compositor | Hyprland |
| Bar | waybar |
| Launcher / menus | rofi (apps, wifi, sound, mic, bluetooth) |
| Terminal | kitty (fish + starship) |
| Notifications | mako |
| Wallpaper | mpvpaper (live video), swaybg fallback |
| Colors | Tokyo Night, static (matugen templates with the palette baked in) |
| Lock / idle / power | hyprlock · hypridle · wlogout |
| Clipboard history | cliphist |
| Auth agent | hyprpolkitagent |

## What's included (`.config/`)

```
hypr/        hyprland.conf, hyprlock.conf, hypridle.conf, colors.conf,
             scripts/ (wallpaper switcher, clipboard menu, screenshot), wallpapers/
waybar/      config.jsonc, style.css, colors.css, scripts/ (mic + rofi menus)
rofi/        config.rasi (apps), menu.rasi (control menus), wifi.rasi, colors.rasi
kitty/       kitty.conf, theme.conf (static Tokyo Night, opaque)
matugen/     config.toml + templates/  (Tokyo Night hardcoded, no wallpaper placeholders)
gtk-3.0/ gtk-4.0/   gtk.css (imports colors.css -> nautilus/GTK apps match)
wlogout/     layout + themed style.css
fish/        config.fish, conf.d/, functions/
Code/User/   settings.json
```

Plus `.local/bin/hypridle-supervise` (restarts hypridle if it dies, logs to
`$XDG_RUNTIME_DIR/hypridle.log`), installed by `install.sh`.

> `colors.*` files are the Tokyo Night palette. matugen still runs on `Super+W`, but
> its templates have the colors baked in, so it rewrites the same palette whatever
> the wallpaper. To theme from the wallpaper again, put `{{colors...}}` placeholders
> back in `matugen/templates/`.

## Install

```bash
git clone https://github.com/<you>/hyprland-dotfiles.git
cd hyprland-dotfiles
# 1) install packages (see packages.txt)
# 2) copy configs into place
cp -r .config/* ~/.config/
# 3) run the installer for post-steps (symlink, chmod, matugen, brightness perms)
./install.sh
```

Then log out and pick **Hyprland** at the login screen.

See **`packages.txt`** for the full dependency list (apt + the few non-apt tools).

## Keybindings (Super = Mod)

| Keys | Action |
|------|--------|
| `Super+Return` / `Super+Q` | Terminal (kitty) |
| `Super+Space` / `Super+D` | App launcher (rofi) |
| `Super+C` | Close window · `Super+V` float · `Super+T` togglesplit |
| `Super+h/j/k/l` | Focus left/down/up/right (arrows too) |
| `Super+Shift+H/J` · `Super+Alt+K/L` | Move window in layout (left/down · up/right) |
| `Super+Shift+L` / `Super+Shift+K` | Send window to external / laptop monitor |
| `Super+1..0` / `Super+Shift+1..0` | Switch / move-to workspace |
| `Super+W` | Wallpaper switcher (static image via swaybg + lockscreen) |
| `Super+Shift+V` | Clipboard history (cliphist) |
| `Super+Ctrl+L` | Lock (hyprlock) · `Super+Escape` power menu (wlogout) |
| `Print` / `Super+Print` | Screenshot region / full → `~/Pictures/Screenshots` + clipboard |
| Scroll on bar modules | volume / mic / brightness ±5% |

## Notes / gotchas (learned the hard way)

- **VS Code, Spotify etc. must NOT be Snaps.** Snap confinement breaks Wayland
  (blurry) and shell-env. Use the official **.deb** (VS Code) / native deb (Spotify).
- **Fractional scaling (1.25) blurs XWayland apps.** Native-Wayland apps are crisp.
  Electron is forced to Wayland via `ELECTRON_OZONE_PLATFORM_HINT=auto` (in
  hyprland.conf). Apps that can't do Wayland (Spotify) are handled by
  `xwayland { force_zero_scaling = true }` (renders them sharp). Find XWayland apps:
  `hyprctl clients -j | python3 -c "import json,sys;[print(c['class']) for c in json.load(sys.stdin) if c['xwayland']]"`
- **Brightness scroll needs the `video` group:** `sudo usermod -aG video $USER`, then re-login.
- **Wallpaper:** live video via `mpvpaper` when `~/.local/bin/mpvpaper` and
  `~/Videos/tlou.webm` both exist (neither ships here; mpvpaper isn't in apt, build it).
  Otherwise falls back to static `swaybg`. Not hyprpaper (rendered blank on this hardware).
- **matugen** isn't in apt (prebuilt binary → `~/.local/bin`). Colors don't depend on it
  any more; it only matters if you restore wallpaper-driven theming.
- **fish + VS Code:** `conf.d/tmux-autostart.fish` is guarded with `isatty stdout`
  so it doesn't break VS Code's shell-env probe.
