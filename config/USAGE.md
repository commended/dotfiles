# Configuration System Usage Examples

This document provides practical examples of using the ricing configuration system.

## Example 1: First Time Setup

```bash
# Clone the repository
git clone https://github.com/commended/ricing ~/.dotfiles
cd ~/.dotfiles

# Install the configuration system
cd config
./install.sh

# Add keybinding to Hyprland
echo 'bind = SUPER, O, exec, open-settings' >> ~/.config/hypr/hyprland.conf
```

## Example 2: Interactive Settings Changes

Press `SUPER + O` to open the settings manager, then:

1. Use ↑/↓ arrows to navigate to "Border Radius"
2. Press Enter to edit
3. Type new value (e.g., "15")
4. Press Enter to confirm
5. Press 's' to save
6. Press 'q' to quit

Your changes are now saved to `~/.config/ricing/settings.yaml`!

## Example 3: Command Line Configuration

```bash
# View current terminal font size
$ settings-manager --get terminal.font_size
12

# Change terminal font size
$ settings-manager --set terminal.font_size 14
Set terminal.font_size = 14

# Toggle blur effects
$ settings-manager --set appearance.blur_enabled false
Set appearance.blur_enabled = False

# Change Waybar position
$ settings-manager --set waybar.position bottom
Set waybar.position = bottom
```

## Example 4: Applying Settings to Config Files

After making changes, generate config snippets:

```bash
$ apply-settings

╔════════════════════════════════════════════════════════════════════╗
║                    APPLYING RICING SETTINGS                        ║
╚════════════════════════════════════════════════════════════════════╝

Applying appearance settings...
  - Border radius: 15px
  - Inner gaps: 5px
  - Outer gaps: 10px
  - Blur: disabled
  → To fully apply, edit ~/.config/hypr/hyprland.conf
     Or run: hyprctl reload

...

======================================================================
HYPRLAND CONFIGURATION SNIPPET
======================================================================
Add this to your ~/.config/hypr/hyprland.conf:

# Generated from ricing settings.yaml
decoration {
    rounding = 15
    
    blur {
        enabled = false
        size = 8
        passes = 2
    }
}
...
```

Copy the generated snippet and add it to your Hyprland config!

## Example 5: Batch Settings Configuration

Create a script to set multiple values:

```bash
#!/bin/bash
# my-custom-settings.sh

# Set appearance
settings-manager --set appearance.border_radius 10
settings-manager --set appearance.gaps_in 8
settings-manager --set appearance.gaps_out 16
settings-manager --set appearance.blur_enabled true

# Set terminal
settings-manager --set terminal.font_size 13
settings-manager --set terminal.opacity 0.9

# Set waybar
settings-manager --set waybar.position top
settings-manager --set waybar.clock_format 12h

echo "Custom settings applied!"
```

## Example 6: Advanced Configuration

For advanced users, directly edit the YAML file:

```bash
# Open in your preferred editor
$ settings-manager --config

# Or directly
$ nano ~/.config/ricing/settings.yaml
```

Example advanced settings you might add:

```yaml
# Custom startup applications
startup_apps:
  - "waybar"
  - "hyprpaper"
  - "dunst"
  - "nm-applet"
  - "blueman-applet"

# Custom scripts
scripts:
  wallpaper_selector: "~/.local/bin/wallpaper-selector"
  cpu_history: "~/.config/waybar/scripts/cpu_history.py"
  custom_script: "~/scripts/my-custom-script.sh"

# Advanced display settings
display:
  monitor_config:
    - name: "DP-1"
      resolution: "2560x1440"
      refresh_rate: 165
      position: "0x0"
    - name: "HDMI-A-1"
      resolution: "1920x1080"
      refresh_rate: 60
      position: "2560x0"
```

## Example 7: Backup and Restore Settings

```bash
# Backup your settings
$ cp ~/.config/ricing/settings.yaml ~/settings-backup.yaml

# Share settings with another machine
$ scp ~/.config/ricing/settings.yaml user@other-machine:~/.config/ricing/

# Restore from backup
$ cp ~/settings-backup.yaml ~/.config/ricing/settings.yaml
$ apply-settings  # Generate new config snippets
```

## Example 8: Integration with Scripts

Use settings in your own scripts:

```bash
#!/bin/bash
# Example: Get wallpaper directory from settings

WALLPAPER_DIR=$(settings-manager --get wallpaper.directory)
echo "Wallpapers are in: $WALLPAPER_DIR"

# Count wallpapers
WALLPAPER_DIR=$(eval echo $WALLPAPER_DIR)  # Expand ~ if present
if [ -d "$WALLPAPER_DIR" ]; then
    COUNT=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | wc -l)
    echo "Found $COUNT wallpapers"
fi
```

## Example 9: Keybinding Shortcuts

Add these to your Hyprland config for quick access:

```conf
# Open settings manager
bind = SUPER, O, exec, open-settings

# Apply settings and reload
bind = SUPER SHIFT, O, exec, apply-settings && hyprctl reload

# Edit config file directly
bind = SUPER CTRL, O, exec, kitty -e settings-manager --config
```

## Example 10: Version Control Your Settings

```bash
# Initialize git in your dotfiles
cd ~/.dotfiles
git add config/

# Track your settings
cd ~/.config/ricing
git init
git add settings.yaml
git commit -m "My ricing settings"

# Push to your own repository
git remote add origin git@github.com:yourusername/my-ricing-settings.git
git push -u origin main
```

## Troubleshooting

### Settings not applying?

1. Make sure you saved changes (press 's' in the manager)
2. Run `apply-settings` to see what needs to be updated
3. Reload components (Hyprland, Waybar, etc.)

### Script not found?

Make sure `~/.local/bin` is in your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### PyYAML import error?

Install PyYAML:
```bash
pip install pyyaml
# or
sudo pacman -S python-yaml  # Arch
sudo apt install python3-yaml  # Ubuntu/Debian
```

## Tips and Tricks

1. **Use tab completion**: If your shell supports it, settings-manager should work with completion
2. **Check values before changing**: Use `--get` to see current values
3. **Keep backups**: Always backup before major changes
4. **Read comments**: The settings.yaml file has helpful comments for each setting
5. **Start simple**: Use the interactive TUI first, then graduate to direct editing

## See Also

- [Main README](../README.md) - General installation and setup
- [Config README](README.md) - Detailed configuration documentation
- [Hyprland Docs](https://wiki.hyprland.org/) - Hyprland configuration reference
