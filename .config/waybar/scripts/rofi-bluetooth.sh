#!/usr/bin/env bash
# Bluetooth menu via rofi + bluetoothctl: power toggle, scan, connect/disconnect.
# Fast: one `devices Connected` call instead of per-device `info`.

THEME="$HOME/.config/rofi/menu.rasi"
menu() { rofi -dmenu -i -config "$THEME" "$@"; }
notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a Bluetooth "$@"; }

power=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2; exit}')
[ -z "$power" ] && { notify "No Bluetooth adapter found"; exit 1; }

if [ "$power" != "yes" ]; then
    sel=$(printf 'Power on Bluetooth\n' | menu -p "Bluetooth (off)")
    [ "$sel" = "Power on Bluetooth" ] && bluetoothctl power on
    exit 0
fi

connected=$(bluetoothctl devices Connected 2>/dev/null)
list=""
while read -r _ mac name; do
    [ -z "$mac" ] && continue
    [ -z "$name" ] && name="$mac"
    if grep -qF "$mac" <<<"$connected"; then
        list+="● ${name}\n"
    else
        list+="  ${name}\n"
    fi
done < <(bluetoothctl devices 2>/dev/null | sort -u)

choice=$(printf '%b%s\n' "$list" $'Scan for devices\nPower off Bluetooth\nOpen blueman' | menu -p "Bluetooth")
[ -z "$choice" ] && exit 0
case "$choice" in
  "Scan for devices")    setsid -f bash -c 'bluetoothctl --timeout 12 scan on >/dev/null 2>&1'; notify "Scanning 12s — reopen the menu after"; exit 0;;
  "Power off Bluetooth") bluetoothctl power off; notify "Bluetooth off"; exit 0;;
  "Open blueman")        setsid -f blueman-manager >/dev/null 2>&1; exit 0;;
esac

name="${choice#● }"; name="${name#  }"
mac=$(bluetoothctl devices 2>/dev/null | grep -F " $name" | awk '{print $2}' | head -1)
[ -z "$mac" ] && exit 0
if grep -qF "$mac" <<<"$connected"; then
    bluetoothctl disconnect "$mac" >/dev/null 2>&1 && notify "Disconnected $name"
else
    notify "Connecting to $name…"
    setsid -f bash -c "bluetoothctl connect '$mac' >/dev/null 2>&1 && notify-send -a Bluetooth 'Connected $name' || notify-send -a Bluetooth 'Failed: $name'"
fi
