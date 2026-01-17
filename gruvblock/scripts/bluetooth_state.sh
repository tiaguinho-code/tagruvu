#!/usr/bin/env bash
set -euo pipefail

# Simple Waybar bluetooth state script
# Outputs a nerd-font glyph plus optional count, e.g. "󰂯 2" or "󰂲 OFF"

powered=""
cnt=0

if command -v bluetoothctl >/dev/null 2>&1 && bluetoothctl show >/dev/null 2>&1; then
  powered=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/ {print $2; exit}' || true)
  mapfile -t devs < <(bluetoothctl devices 2>/dev/null | awk '{print $2}')
  for d in "${devs[@]:-}"; do
    if bluetoothctl info "$d" 2>/dev/null | grep -q "Connected: yes"; then
      cnt=$((cnt+1))
    fi
  done
elif command -v gdbus >/dev/null 2>&1; then
  # Query BlueZ over DBus for managed objects and parse Powered and Connected flags
  objs=$(gdbus call --system --dest org.bluez --object-path / --method org.freedesktop.DBus.ObjectManager.GetManagedObjects 2>/dev/null || true)
  if [ -n "$objs" ]; then
    # normalize to single line for robust matching
    one=$(printf "%s" "$objs" | tr '\n' ' ')
    # Count occurrences of Connected true (handles <true>, true, and 'true')
    cnt=$(printf "%s" "$one" | grep -oE "Connected[^[:alnum:]]*(<true>|true|'true')" | wc -l || true)
    # Detect Powered true or PowerState 'on'
    if printf "%s" "$one" | grep -E "(Powered[^[:alnum:]]*(<true>|true|'true')|PowerState[^[:alnum:]]*<'?on'?>)" >/dev/null 2>&1; then
      powered="yes"
    else
      powered="no"
    fi
  fi
else
  # no bluetoothctl or gdbus; leave powered empty and cnt at 0
  powered=""
  cnt=0
fi

# If any device is connected, show connected glyph with count.
ICON_CONNECTED="󰂯"
ICON_ON="󰂱"
ICON_OFF="󰂲"

LEFT_BG="#E78A4E"
LEFT_FG="#202020"
RIGHT_BG="#202020"
RIGHT_FG="#ebdbb2"

# Output format: left colored glyph (black glyph on chosen gruvbox color),
# right side white-on-black with count or state, matching network/cpu look.
if [ "$cnt" -gt 0 ]; then
  # left colored glyph, right count with transparent background
  printf "%s\n" "<span color='${LEFT_FG}' bgcolor='${LEFT_BG}'> ${ICON_CONNECTED} </span> <span color='${RIGHT_FG}'> ${cnt} </span>"
  exit 0
fi

# If no connected devices, but adapter reports Powered: yes, show ON (no connections)
if [ "$powered" = "yes" ]; then
  printf "%s\n" "<span color='${LEFT_FG}' bgcolor='${LEFT_BG}'> ${ICON_ON} </span> <span> ON </span>"
  exit 0
fi

# # Fallback: check rfkill to detect if bluetooth is blocked/unavailable.
# if command -v rfkill >/dev/null 2>&1; then
#   blk=$(rfkill list bluetooth 2>/dev/null | awk -F': ' '/Soft blocked/ {print $2; exit}') || true
#   if [ "$blk" = "no" ]; then
#     printf "%s\n" "󰂱"
#     exit 0
#   fi
# fi

## Fallback: check systemd service state
#if command -v systemctl >/dev/null 2>&1; then
#  if systemctl is-active --quiet bluetooth 2>/dev/null; then
#    printf "%s\n" "󰂱"
#    exit 0
#  fi
#fi

# Default: OFF
printf "%s\n" "<span color='${LEFT_FG}' bgcolor='${LEFT_BG}'> ${ICON_OFF} </span> <span> OFF </span>"
exit 0
