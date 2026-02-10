#!/bin/bash

dir=$(date +"$HOME/Pictures/Screenshots/%Y/%m/%d")
file=$(date +"$HOME/Pictures/Screenshots/%Y/%m/%d/%Y-%m-%d_%H-%M-%S.png")

mkdir -p -- "$dir"

geometry=$(slurp) || exit 0
grim -g "$geometry" "$file" && \
  wl-copy < "$file" && \
  notify-send "Screenshot" "Region saved to $file"

