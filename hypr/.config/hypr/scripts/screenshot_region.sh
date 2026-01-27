#!/bin/bash
file="$HOME/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
grim -g "$(slurp)" "$file" && wl-copy < "$file" && notify-send "Screenshot" "Region saved to $file"
