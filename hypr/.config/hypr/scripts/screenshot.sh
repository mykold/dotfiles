#!/bin/bash
file="$HOME/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
grim "$file" && wl-copy < "$file" && notify-send "Screenshot" "Saved to $file"
