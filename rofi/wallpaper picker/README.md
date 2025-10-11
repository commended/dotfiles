# Wallpaper Selector

A rofi-based wallpaper selector for Hyprland with optional pywal color scheme integration.

## Features

- Visual thumbnail previews in rofi
- Fast wallpaper switching with hyprpaper
- Optional pywal color scheme updates
- Configurable through environment variables or config file

## Configuration

### Enabling/Disabling Pywal

You can control pywal color updates in several ways:

1. **Via environment variable (temporary):**
   ```bash
   ENABLE_PYWAL=false wallpaper-selector
   ```

2. **Via config file (persistent):**
   Create `~/.config/wallpaper-selector/config`:
   ```bash
   mkdir -p ~/.config/wallpaper-selector
   cp config.example ~/.config/wallpaper-selector/config
   # Edit the file to set ENABLE_PYWAL="false"
   ```

3. **Default behavior:**
   If not configured, pywal is enabled by default.

## What Pywal Does

When enabled, pywal will:
- Generate a color scheme from your wallpaper
- Update terminal colors (requires terminal restart or source ~/.zshrc)
- Reload waybar colors
- Update Neovim colors (for running instances)
- Restart wofi to apply new colors

## Requirements

- rofi
- hyprctl (Hyprland)
- hyprpaper
- ImageMagick (for thumbnails)
- pywal (optional, for color scheme updates)
