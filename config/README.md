# Configuration System

This directory contains the centralized configuration system for your Hyprland rice.

## Files

- **settings.yaml** - Main configuration file with all settings
- **settings-manager** - Interactive TUI for editing settings (press 'o' to open)
- **open-settings** - Quick launcher script for the settings manager

## Quick Start

### Interactive Settings Editor

Press `SUPER + O` (or run `./config/open-settings`) to open the interactive settings editor.

In the editor:
- **↑/↓** - Navigate through settings
- **Enter** - Edit the selected setting
- **s** - Save changes
- **r** - Reload settings from file
- **q** - Quit

### Command Line Usage

```bash
# View a specific setting
./config/settings-manager --get appearance.border_radius

# Change a setting
./config/settings-manager --set appearance.border_radius 15

# Open config file in your editor
./config/settings-manager --config

# Show help
./config/settings-manager --help
```

## Configuration Categories

### Display Settings
- Monitor refresh rate, resolution, and scaling

### Appearance
- Border radius, width, gaps, animations
- Blur effects and opacity settings

### Waybar
- Position, modules visibility, CPU graph settings
- Clock format preferences

### Terminal
- Default terminal, font, size, opacity
- Ligature support

### Launcher
- Wofi/Rofi selection
- Display settings (lines, width, icons)

### Wallpaper
- Directory path
- Auto color generation from wallpaper
- Auto-change interval

### Lock Screen
- Timeout settings
- Lock on suspend
- Clock display

### Input
- Keyboard repeat rate and delay
- Touchpad settings (tap-to-click, natural scrolling)
- Mouse acceleration

### Keybindings
- Simplified keybinding presets
- Note: For full customization, edit `~/.config/hypr/hyprland.conf` directly

### Notifications
- Timeout and position
- History settings

### Performance
- VRR (Variable Refresh Rate)
- Render backend selection
- Hardware cursor support

### Startup Applications
- List of applications to launch on startup

### Custom Scripts
- Paths to custom scripts

## Installation

After cloning the repository, symlink the config directory:

```bash
mkdir -p ~/.config/ricing
ln -s ~/.dotfiles/config/settings.yaml ~/.config/ricing/settings.yaml
ln -s ~/.dotfiles/config/settings-manager ~/.local/bin/settings-manager
ln -s ~/.dotfiles/config/open-settings ~/.local/bin/open-settings
```

Or copy the files:

```bash
mkdir -p ~/.config/ricing
cp config/settings.yaml ~/.config/ricing/
cp config/settings-manager ~/.local/bin/
cp config/open-settings ~/.local/bin/
chmod +x ~/.local/bin/settings-manager ~/.local/bin/open-settings
```

### Add Keybinding to Hyprland

Add this to your `~/.config/hypr/hyprland.conf`:

```conf
# Open settings manager
bind = SUPER, O, exec, open-settings
```

Or if you haven't installed to `~/.local/bin`:

```conf
bind = SUPER, O, exec, ~/.dotfiles/config/open-settings
```

## Advanced Configuration

For advanced users, you can directly edit `~/.config/ricing/settings.yaml` or the default `config/settings.yaml` in your text editor. The file is well-commented with descriptions for each setting.

After making changes, some settings may require restarting components:
- Hyprland: `hyprctl reload` or logout/login
- Waybar: `killall waybar && waybar &`
- Terminal: Close and reopen terminal windows

## Python Dependencies

The settings manager requires:
- Python 3.6+
- PyYAML

Install with:
```bash
pip install pyyaml
```

or

```bash
sudo pacman -S python-yaml  # Arch Linux
sudo apt install python3-yaml  # Debian/Ubuntu
```
