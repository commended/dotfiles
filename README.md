# ricing

My Wayland/Hyprland dotfiles
> enjoy!

## Contents

Current components included:
- hyprlock (lock screen styling)
- waybar (status bar)
- kitty (terminal emulator config)
- wofi (app launcher)
- fastfetch (system info banner)
- zsh (system shell)
- lazyvim (text editor)
- starship (fetch prompt)
- rofi wallpaper slector
- **config system** (centralized settings with interactive editor)
- more soon!


## Prerequisites
Make sure you have
- Hyprland
- hyprlock (if packaged separately)
- hyprpaper
- waybar (Wayland bar)
- kitty
- wofi
- fastfetch
- wl-clipboard, grim, slurp (for screenshots / clipboard helpers)
- swappy (optional screenshot editor)
- pamixer or wireplumber (audio control)
- playerctl (media control)
- NetworkManager + nm-applet (if using network tray icon)
- FiraCode Nerd Font (or any Nerd Font) for icons/glyphs
- rofi
- ImageMagick
- Python 3.6+ with PyYAML (for settings manager)

## Install (Quick Start)
```bash
# 1. Clone into a dotfiles directory
git clone https://github.com/commended/ricing ~/.dotfiles
cd ~/.dotfiles


# 3. Create needed target directory
mkdir -p ~/.config

# 4. Symlink each component
ln -s ~/.dotfiles/hyprlock ~/.config/hyprlock
ln -s ~/.dotfiles/waybar ~/.config/waybar
ln -s ~/.dotfiles/kitty ~/.config/kitty
ln -s ~/.dotfiles/wofi ~/.config/wofi
ln -s ~/.dotfiles/fastfetch ~/.config/fastfetch

# 5. Install settings manager (optional but recommended)
cd ~/.dotfiles/config
./install.sh


If you prefer copying instead of symlinking:
```bash
cp -r hyprlock waybar kitty wofi fastfetch ~/.config/

```
## Updating
```bash
cd ~/.dotfiles
git pull --rebase
# (Symlinks will automatically point to the updated files.)
```
If you copied files instead of symlinking, re-copy the changed directories manually.

## Configuration

### Interactive Settings Manager

Press **SUPER + O** to open the interactive settings editor (after adding the keybinding).

To add the keybinding, add this to `~/.config/hypr/hyprland.conf`:
```conf
bind = SUPER, O, exec, open-settings
```

The settings manager provides a user-friendly interface to edit:
- Appearance (borders, gaps, animations, blur, opacity)
- Waybar settings (position, modules, CPU graph)
- Terminal settings (font, size, opacity)
- Wallpaper settings (directory, auto-colors)
- Lock screen settings (timeout, display options)
- And more!

For advanced configuration, directly edit `~/.config/ricing/settings.yaml`. See [config/README.md](config/README.md) for full documentation.

## Customization Notes
- Themes / Colors: Centralize palette variables in your Waybar css and reuse in kitty & wofi for consistency.
- Fonts: Ensure a Nerd Font is installed; update kitty.conf + Waybar JSON accordingly.
- Icons: Waybar modules may require Font Awesome or Material Design icons included in selected Nerd Font.
- Settings: Use the interactive settings manager (SUPER + O) for basic configuration, or edit `~/.config/ricing/settings.yaml` for advanced options.
