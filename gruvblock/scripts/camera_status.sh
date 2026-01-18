#!/bin/bash

# State file to track camera status
STATE_FILE="/tmp/camera_state"

# Initialize state file if it doesn't exist (default: ON)
if [ ! -f "$STATE_FILE" ]; then
    echo "ON" > "$STATE_FILE"
fi

# Read current state
state=$(cat "$STATE_FILE")

if [ "$state" = "ON" ]; then
    echo "<span color='#202020' bgcolor='#689d6a' > 󰄀 </span>"
else
    echo "<span color='#202020' bgcolor='#ea6962' > 󰗟 </span>"
fi
