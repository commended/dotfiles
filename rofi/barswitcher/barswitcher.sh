#!/usr/bin/env bash

# Bar Switcher Script
# Switches between different Waybar configurations

WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
ROFI_CONFIG="$HOME/.config/rofi/barswitcher/barswitcher.rasi"

# Function to switch to top bar
switch_to_top() {
  # Copy top config and style
  cp "$WAYBAR_CONFIG_DIR/configtop.jsonc" "$WAYBAR_CONFIG_DIR/config.jsonc"
  cp "$WAYBAR_CONFIG_DIR/styletop.css" "$WAYBAR_CONFIG_DIR/style.css"
  
  # Reload waybar
  pkill waybar
  sleep 0.2
  waybar &
  
  notify-send "Waybar" "Switched to top bar"
}

# Function to switch to bottom bar
switch_to_bottom() {
  # Copy bottom config and style
  cp "$WAYBAR_CONFIG_DIR/bottomconfig.jsonc" "$WAYBAR_CONFIG_DIR/config.jsonc"
  cp "$WAYBAR_CONFIG_DIR/bottomstyle.css" "$WAYBAR_CONFIG_DIR/style.css"
  
  # Reload waybar
  pkill waybar
  sleep 0.2
  waybar &
  
  notify-send "Waybar" "Switched to bottom bar"
}

# Main menu
selected=$(echo -e "Top\nBottom" | rofi -dmenu -i -p "Bar Position" -theme "$ROFI_CONFIG")

case "$selected" in
  "Top") switch_to_top ;;
  "Bottom") switch_to_bottom ;;
esac
