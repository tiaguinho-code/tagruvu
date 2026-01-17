#!/usr/bin/env bash
set -euo pipefail

# Minimal keyboard language indicator and cycler for Hyprland
# Usage:
#   keyboard_layout.sh          -> prints current language (e.g. " BR")
#   keyboard_layout.sh cycle    -> cycles layouts for all keyboards via hyprctl

cmd=${1:-}

if [ "$cmd" = "cycle" ] || [ "$cmd" = "switch" ] || [ "$cmd" = "toggle" ]; then
  if command -v jq >/dev/null 2>&1; then
    hyprctl --batch "$(hyprctl devices -j | jq -r '.keyboards[] | .name' | while IFS= read -r keyboard; do printf '%s %s %s;' 'switchxkblayout' "${keyboard}" 'next'; done)" || true
  else
    hyprctl --batch "$(hyprctl devices | awk '/^Keyboards:/{ins=1;next}/^Tablets:/{ins=0} ins && /^\s+[^[:space:]]/{gsub(/:$/,"",$1); printf "switchxkblayout %s next;", $1 }')" || true
  fi
  exit 0
fi

# Print current language (two-letter uppercase) using hyprctl + jq when available
if command -v jq >/dev/null 2>&1; then
  lang=$(hyprctl devices -j | jq -r '.keyboards[] | .active_keymap' | head -n1 | cut -c1-2 | tr 'a-z' 'A-Z' 2>/dev/null || true)
else
  lang=$(hyprctl devices 2>/dev/null | awk '/active keymap/ {print $NF; exit}' | cut -c1-2 | tr 'a-z' 'A-Z' || true)
fi

printf "%s %s\n" "" "${lang:---}"
