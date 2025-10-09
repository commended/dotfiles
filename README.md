# ricing

My personal Wayland/Hyprland dotfiles
> NOTE: Always back up your existing configuration

## Contents

Current components included:
- hyprlock (lock screen styling)
- waybar (status bar)
- kitty (terminal emulator config)
- wofi (app launcher)
- fastfetch (system info banner)
- zsh (system shell)
- lazyvim (text editor)
- starships (fetch prompt)
- rofi wallpaper slector
- web search (quick web search via wofi)
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
- jq (for web search URL encoding)
- xdg-utils (for opening URLs in browser)

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

## Key Bindings
- `Super + R` - Launch application launcher (wofi)
- `Super + S` - Web search (opens wofi prompt for search query)
- `Super + P` - Wallpaper selector
- `Super + C` - Close active window
- `Super + M` - Lock screen
- `Ctrl + Alt + T` - Open terminal (kitty)

## Customization Notes
- Themes / Colors: Centralize palette variables in your Waybar css and reuse in kitty & wofi for consistency.
- Fonts: Ensure a Nerd Font is installed; update kitty.conf + Waybar JSON accordingly.
- Icons: Waybar modules may require Font Awesome or Material Design icons included in selected Nerd Font.
- Web Search: Edit `scripts/web-search` to change the default search engine (google, brave, duckduckgo, or bing).
