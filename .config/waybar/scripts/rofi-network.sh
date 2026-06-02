#!/usr/bin/env bash
# Full NetworkManager menu via rofi + nmcli: Wi-Fi toggle (always shown),
# wired connections, Wi-Fi networks, and Edit connections. Active marked with ●.

THEME="$HOME/.config/rofi/menu.rasi"
menu() { rofi -dmenu -i -config "$THEME" "$@"; }
notify() { command -v notify-send >/dev/null 2>&1 && notify-send -a Network "$@"; }

wifi_state=$(nmcli -t -f WIFI radio 2>/dev/null)

opts=""
# Wi-Fi on/off toggle — ALWAYS present so it can be re-enabled
if [ "$wifi_state" = "enabled" ]; then
    opts+="Disable Wi-Fi\n"
else
    opts+="Enable Wi-Fi\n"
fi

# Wired (ethernet) connection profiles
while IFS=: read -r name typ _dev; do
    [ "$typ" = "802-3-ethernet" ] || continue
    if nmcli -t -f NAME connection show --active 2>/dev/null | grep -qx "$name"; then
        opts+="Disconnect wired: $name\n"
    else
        opts+="Connect wired: $name\n"
    fi
done < <(nmcli -t -f NAME,TYPE,DEVICE connection show 2>/dev/null)

# Wi-Fi networks (only if radio on)
if [ "$wifi_state" = "enabled" ]; then
    nmcli device wifi rescan >/dev/null 2>&1; sleep 0.4
    while IFS=: read -r act ssid sig; do
        [ -z "$ssid" ] && continue
        pre="  "; [ "$act" = "yes" ] && pre="● "
        opts+="${pre}${ssid}  ·  ${sig}%\n"
    done < <(nmcli -t -e no -f ACTIVE,SSID,SIGNAL device wifi list 2>/dev/null | awk -F: '$2!="" && !seen[$2]++')
fi

opts+="Edit connections…"

choice=$(printf '%b' "$opts" | menu -p "Network")
[ -z "$choice" ] && exit 0

case "$choice" in
  "Enable Wi-Fi")        nmcli radio wifi on;  notify "Wi-Fi enabled";  exit 0;;
  "Disable Wi-Fi")       nmcli radio wifi off; notify "Wi-Fi disabled"; exit 0;;
  "Edit connections…")   setsid -f nm-connection-editor >/dev/null 2>&1; exit 0;;
  "Connect wired: "*)    nmcli connection up   id "${choice#Connect wired: }"    >/dev/null 2>&1 && notify "Wired connected"; exit 0;;
  "Disconnect wired: "*) nmcli connection down id "${choice#Disconnect wired: }" >/dev/null 2>&1 && notify "Wired disconnected"; exit 0;;
esac

# Otherwise: a Wi-Fi SSID was chosen — strip ● marker and trailing "  ·  NN%"
ssid="${choice#● }"; ssid="${ssid#  }"; ssid="${ssid%  ·  *}"
[ -z "$ssid" ] && exit 0
if nmcli -t -f NAME connection show 2>/dev/null | grep -qx "$ssid"; then
    nmcli connection up id "$ssid" >/dev/null 2>&1 && notify "Connected to $ssid" || notify "Failed: $ssid"
else
    if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
        notify "Connected to $ssid"
    else
        pass=$(printf '' | menu -password -p "Password ($ssid)")
        [ -z "$pass" ] && exit 0
        nmcli device wifi connect "$ssid" password "$pass" >/dev/null 2>&1 \
            && notify "Connected to $ssid" || notify "Failed: $ssid"
    fi
fi
