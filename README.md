# ricing

My personal Wayland/Hyprland dotfiles. Minimal, fast, and themed for a cohesive look. Feel free to fork or copy pieces you like.

> NOTE: Always back up your existing configuration before replacing it with mine.

## Contents

Current components included:
- hyprlock (lock screen styling)
- waybar (status bar)
- kitty (terminal emulator config)
- wofi (app launcher)
- fastfetch (system info banner)
- more soon

## Preview
(Add screenshots or a short GIF here if you want. Example placeholders: `screenshots/desktop.png`, `screenshots/lockscreen.png`.)

## Prerequisites
Make sure you have (package names are for Arch-based distros — adjust for your distro):
- Hyprland
- hyprlock (if packaged separately)
- waybar (Wayland bar)
- kitty
- wofi (or rofi-wayland if you prefer)
- fastfetch
- wl-clipboard, grim, slurp (for screenshots / clipboard helpers)
- swappy (optional screenshot editor)
- pamixer or wireplumber (audio control)
- playerctl (media control)
- NetworkManager + nm-applet (if using network tray icon)
- FiraCode Nerd Font (or any Nerd Font) for icons/glyphs

## Install (Quick Start)
```bash
# 1. Clone into a dotfiles directory
git clone https://github.com/commended/ricing ~/.dotfiles
cd ~/.dotfiles

# 2. Backup any existing configs you might overwrite
backup_dir=~/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)
mkdir -p "$backup_dir"
for d in hyprlock waybar kitty wofi fastfetch; do
  if [ -e "$HOME/.config/$d" ]; then
    echo "Backing up $HOME/.config/$d -> $backup_dir/$d"
    mv "$HOME/.config/$d" "$backup_dir/" 2>/dev/null
  fi
done

# 3. Create needed target directory
mkdir -p ~/.config

# 4. Symlink each component
ln -s ~/.dotfiles/hyprlock ~/.config/hyprlock
ln -s ~/.dotfiles/waybar ~/.config/waybar
ln -s ~/.dotfiles/kitty ~/.config/kitty
ln -s ~/.dotfiles/wofi ~/.config/wofi
ln -s ~/.dotfiles/fastfetch ~/.config/fastfetch

# 5. (Optional) reload / start services
# Restart Hyprland session or run:
#   killall waybar; waybar &
#   hyprlock &
```

If you prefer copying instead of symlinking:
```bash
cp -r hyprlock waybar kitty wofi fastfetch ~/.config/
```

## Directory Layout
```
ricing/
 ├─ hyprlock/        # Hyprlock config + assets
 ├─ waybar/          # Waybar config, style.css, scripts
 ├─ kitty/           # kitty.conf, themes
 ├─ wofi/            # style.css, config
 └─ fastfetch/       # fastfetch.jsonc or config file
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
- Fastfetch: Edit its config file inside `fastfetch/` to reflect your hardware preferences.

## Troubleshooting
| Issue | Fix |
|-------|-----|
| Waybar not showing icons | Install a Nerd Font and restart Waybar |
| Hyprlock fails to start | Ensure `hyprlock` binary installed & auth modules configured (PAM) |
| Kitty font incorrect | Check `font_family` in kitty.conf matches installed font name |
| Wofi theme not applied | Confirm `style.css` path and that no system-wide theme overrides it |
| Fastfetch misaligned | Use a monospace Nerd Font & adjust padding in config |

## Removal / Revert
```bash
rm ~/.config/hyprlock ~/.config/waybar ~/.config/kitty ~/.config/wofi ~/.config/fastfetch
# Restore from backup if needed
cp -r "$backup_dir"/* ~/.config/
```

## Roadmap / TODO
- Add install script (automate backup + symlinks)
- Add screenshot assets
- Add theme variants
- Add optional script helpers (volume, brightness, notifications)

## Contributing
Open an issue or a PR with suggestions. Keep things minimal and theme-consistent.

## License
Add a LICENSE file if you want explicit terms (MIT recommended). Currently assumed personal use reference.

---
Enjoy and happy ricing!