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

# Print current language (two-letter uppercase) using hyprctl + jq when available.
# Prefer device matching "k380", then a device marked main, then the first non-virtual keyboard.
if command -v jq >/dev/null 2>&1; then
  lang=$(hyprctl devices -j 2>/dev/null | jq -r '
    [ ( .keyboards[] | select(.name|test("k380";"i")) | .active_keymap ),
      ( .keyboards[] | select(.main==true or .main=="yes" or .main==1) | .active_keymap ),
      ( .keyboards[] | select( (.name|test("virtual|fcitx|hl-virtual";"i")) | not ) | .active_keymap ),
      ( .keyboards[] | .active_keymap ) ]
    | map(select(.!=null and .!="")) | .[0]
  ' 2>/dev/null | cut -c1-2 | tr 'a-z' 'A-Z') || true
else
  lang=$(hyprctl devices 2>/dev/null | awk '
    /^[^ \t]/ { name=$1; gsub(/:$/,"",name); next }
    /active keymap:/ { sub(/.*active keymap:[ \t]*/,"",$0); active[name]=$0 }
    /main:/ { if ($0 ~ /yes/) main[name]=1 }
    END {
      # prefer k380
      for (n in active) if (tolower(n) ~ /k380/) { print active[n]; exit }
      # prefer main
      for (n in active) if (main[n]) { print active[n]; exit }
      # prefer non-virtual
      for (n in active) if (tolower(n) !~ /virtual|fcitx|hl-virtual/) { print active[n]; exit }
      # else any
      for (n in active) { print active[n]; exit }
    }' | cut -c1-2 | tr 'a-z' 'A-Z') || true
fi

# Hardcoded replacements
case "$lang" in
  PO) lang="BR" ;;
  GE) lang="DE" ;;
  KO) lang="KR" ;;
esac

printf "%s\n" "${lang:---}"
