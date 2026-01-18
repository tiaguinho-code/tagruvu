#!/usr/bin/env bash
set -euo pipefail

# Open applications on specific workspaces
# evince on 2, anki on 4, obsidian on 3, ghostty with timr on 2, spotify on 8

hyprctl dispatch workspace 2
evince &

hyprctl dispatch workspace 4
anki &

hyprctl dispatch workspace 3
obsidian &

hyprctl dispatch workspace 2
ghostty -e timr &

hyprctl dispatch workspace 8
spotify &
