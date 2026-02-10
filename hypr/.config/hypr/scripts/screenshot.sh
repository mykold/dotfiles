#!/bin/bash

dir=$(date +"$HOME/Pictures/Screenshots/%Y/%m/%d")
file=$(date +"$HOME/Pictures/Screenshots/%Y/%m/%d/%Y-%m-%d_%H-%M-%S.png")

mkdir -p -- "$dir"

grim "$file" && \
  wl-copy < "$file" && \
  notify-send "Screenshot" "Saved to $file"

