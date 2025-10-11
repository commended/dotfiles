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
- pywal (optional, for dynamic color scheme generation)

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

## Customization Notes
- Themes / Colors: Centralize palette variables in your Waybar css and reuse in kitty & wofi for consistency.
- Fonts: Ensure a Nerd Font is installed; update kitty.conf + Waybar JSON accordingly.
- Icons: Waybar modules may require Font Awesome or Material Design icons included in selected Nerd Font.
- Pywal Integration: The wallpaper selector can automatically update your color scheme using pywal. See `rofi/wallpaper picker/README.md` for configuration options.
