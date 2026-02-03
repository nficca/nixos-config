#!/usr/bin/env bash

# Wallpaper rotation script for awww
WALLPAPER_DIR="$HOME/.config/niri/wallpapers"
INTERVAL=3600 # Change wallpaper every 5 minutes (in seconds)

# Wait for awww-daemon to be ready
sleep 2

while true; do
  # Get a random wallpaper from the directory
  wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)

  if [ -n "$wallpaper" ]; then
    # Set the wallpaper
    # Use awww img --help to see more options
    awww img "$wallpaper" --transition-type wipe --transition-angle 30
  fi

  sleep "$INTERVAL"
done
