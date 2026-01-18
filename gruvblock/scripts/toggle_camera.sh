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
    # Turn camera off
    echo "OFF" > "$STATE_FILE"
    
    # Kill any camera processes
    pkill -f "video" 2>/dev/null || true
    
    # Disable camera devices (requires root/sudo access, may not work without permissions)
    for dev in /dev/video*; do
        [ -e "$dev" ] && chmod 000 "$dev" 2>/dev/null || true
    done
    
    notify-send "Camera" "Camera disabled" -t 2000
else
    # Turn camera on
    echo "ON" > "$STATE_FILE"
    
    # Re-enable camera devices (requires root/sudo access, may not work without permissions)
    for dev in /dev/video*; do
        [ -e "$dev" ] && chmod 666 "$dev" 2>/dev/null || true
    done
    
    notify-send "Camera" "Camera enabled" -t 2000
fi
