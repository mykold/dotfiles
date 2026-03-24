#!/bin/bash

dir=$(date +"$HOME/Pictures/Screenshots/%Y/%m/%d")
file=$(date +"$HOME/Pictures/Screenshots/%Y/%m/%d/%Y-%m-%d_%H-%M-%S.png")

mkdir -p -- "$dir"

geometry=$(
  hyprctl activewindow -j | jq -r '
    select(.at and .size) |
    "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"
  '
) || exit 1

[ -n "$geometry" ] || exit 0

grim -g "$geometry" "$file" || exit 1

wl-copy < "$file"
notify-send "Screenshot" "Window saved to $file"
