#!/bin/bash

# Check if default source (microphone) is muted
muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | grep -o 'yes\|no')

if [ "$muted" = "yes" ]; then
    echo "<span color='#202020' bgcolor='#ea6962' >  </span>"
else
    echo "<span color='#202020' bgcolor='#689d6a' >  </span>"
fi
