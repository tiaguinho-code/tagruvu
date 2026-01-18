#!/bin/bash

# Toggle microphone mute state
pactl set-source-mute @DEFAULT_SOURCE@ toggle

# Check new state and send notification
muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | grep -o 'yes\|no')

if [ "$muted" = "yes" ]; then
    notify-send "Microphone" "Muted" -t 2000
else
    notify-send "Microphone" "Unmuted" -t 2000
fi
