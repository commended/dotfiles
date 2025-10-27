# ricing

My Wayland/Hyprland dotfiles – A complete rice configuration for a beautiful Linux desktop experience.

> **showcase**

![](https://github.com/commended/ricing/blob/main/misc/showcase/windows.png)
![](https://github.com/commended/ricing/blob/main/misc/showcase/nvim.png)
![](https://github.com/commended/ricing/blob/main/misc/showcase/walls.png)
![](https://github.com/commended/ricing/blob/main/misc/showcase/browser.png)

## What's Included

This dotfiles repository includes configurations for:

- **hyprland** - Main window manager configuration (including hyprlock & hyprpaper)
- **waybar** - Sleek status bar with custom modules
- **kitty** - Fast GPU-accelerated terminal emulator
- **wofi** - Application launcher
- **rofi** - Wallpaper selector and more
- **fastfetch** - System information display
- **zsh** - Enhanced shell configuration
- **starship** - Beautiful shell prompt
- **nvim** - LazyVim text editor setup
- **rmpc** - MPD client configuration
- **cava** - Console audio visualizer
- **yazi** - Terminal file manager

## Prerequisites

### Core Requirements
These are essential for the basic setup:

```bash
# Arch Linux / Manjaro
sudo pacman -S hyprland waybar kitty wofi rofi fastfetch zsh starship

# Fedora
sudo dnf install hyprland waybar kitty wofi rofi fastfetch zsh starship

# Ubuntu / Debian (some packages may need manual installation or PPAs)
sudo apt install waybar kitty wofi rofi fastfetch zsh
```

### Additional Dependencies
For full functionality, install these tools:

**Wayland utilities:**
- `wl-clipboard` - Clipboard manager
- `grim` - Screenshot tool
- `slurp` - Screen region selector
- `swappy` - Screenshot editor (optional)

**System tools:**
- `hyprlock` - Screen locker (may be bundled with Hyprland)
- `hyprpaper` - Wallpaper manager
- `pamixer` or `wireplumber` - Audio control
- `playerctl` - Media player control
- `NetworkManager` + `nm-applet` - Network management

**Programming languages and package managers:**
- `rust` and `cargo` - Required for Rust-based tools (rmpc, basalt, kotofetch, dotter)
- `python3` - Required for Python scripts
- `python3-psutil` or `python-psutil` - Python library for system monitoring (used in waybar scripts)

**Color scheme and theming:**
- `pywal` (python-pywal) - Dynamic colorscheme generator, required by zsh configuration
  ```bash
  # Arch Linux / Manjaro
  sudo pacman -S python-pywal
  
  # Fedora
  sudo dnf install python3-pywal
  
  # Ubuntu / Debian
  pip3 install pywal
  ```

**Music and audio:**
- `mpd` (Music Player Daemon) - Required for rmpc music client
- `mpc` - Command-line MPD client (optional, for controlling mpd)

**Fonts:**
- A Nerd Font (e.g., FiraCode Nerd Font) - Required for icons/glyphs
- Install from [Nerd Fonts](https://www.nerdfonts.com/)

**Optional but recommended:**
- `nvim` (Neovim) - For text editing
- `cava` - Audio visualizer
- `yazi` - File manager
- `thunar` - GUI file manager (referenced in zsh aliases)
- `ImageMagick` - Image manipulation for scripts
- `cbonsai` - Terminal bonsai tree (decorative)
- `tty-clock` - Terminal clock (decorative)
- `pipes.sh` - Terminal pipes screensaver (decorative)
- `asciiquarium` - Terminal aquarium (decorative)

## Installation

### Quick Install (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/commended/ricing ~/.dotfiles
cd ~/.dotfiles

# 2. Backup existing configs (if any)
mkdir -p ~/.config/backups
for dir in hyprland waybar kitty wofi rofi fastfetch zsh starship nvim cava yazi; do
  [ -d ~/.config/$dir ] && mv ~/.config/$dir ~/.config/backups/$dir.backup
done

# 3. Create symlinks for all components
mkdir -p ~/.config
ln -sf ~/.dotfiles/hyprland ~/.config/hypr
ln -sf ~/.dotfiles/waybar ~/.config/waybar
ln -sf ~/.dotfiles/kitty ~/.config/kitty
ln -sf ~/.dotfiles/wofi ~/.config/wofi
ln -sf ~/.dotfiles/rofi ~/.config/rofi
ln -sf ~/.dotfiles/fastfetch ~/.config/fastfetch
ln -sf ~/.dotfiles/starship ~/.config/starship
ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/nvim ~/.config/nvim
ln -sf ~/.dotfiles/cava ~/.config/cava
ln -sf ~/.dotfiles/yazi ~/.config/yazi
ln -sf ~/.dotfiles/rmpc ~/.config/rmpc

# 4. Set zsh as default shell (optional)
chsh -s $(which zsh)

# 5. Reload or restart Hyprland
# Log out and log back in, or run: hyprctl reload
```

### Alternative: Copy Files

If you prefer copying files instead of symlinking:

```bash
cd ~/.dotfiles
cp -r hyprland ~/.config/hypr
cp -r waybar kitty wofi rofi fastfetch starship nvim cava yazi rmpc ~/.config/
cp zsh/.zshrc ~/
```

**Note:** With this method, you'll need to manually update files when pulling changes.

## Updating

With symlinks (recommended method):
```bash
cd ~/.dotfiles
git pull
# Symlinks automatically point to updated files - no additional steps needed!
```

With copied files:
```bash
cd ~/.dotfiles
git pull
# Re-copy modified components
cp -r waybar kitty wofi rofi fastfetch ~/.config/
cp zsh/.zshrc ~/
```

## Customization

### Color Themes
- Most color schemes use consistent variables across components
- Edit Waybar CSS for status bar colors: `~/.config/waybar/style.css`
- Edit Kitty colors: `~/.config/kitty/kitty.conf`
- Wofi colors: `~/.config/wofi/style.css`

### Fonts
- Ensure a Nerd Font is installed for proper icon display
- Update font settings in:
  - Kitty: `~/.config/kitty/kitty.conf`
  - Waybar: `~/.config/waybar/config`
  - Hyprland: `~/.config/hypr/hyprland.conf`

### Key Bindings
- Main keybindings are in `~/.config/hypr/hyprland.conf`
- Customize to your preferences

## Troubleshooting

**Icons not displaying?**
- Install a Nerd Font and configure it in your terminal and Waybar

**Waybar not showing?**
- Check if waybar is running: `ps aux | grep waybar`
- Restart: `killall waybar && waybar &`

**Hyprland config errors?**
- Check logs: `hyprctl logs`
- Validate config: `hyprland --check`

**Zsh not loading properly?**
- Make sure Starship is installed: `starship --version`
- Source your config: `source ~/.zshrc`

## Notes

- Some scripts may reference absolute paths - update these to match your system
- The setup assumes a Wayland/Hyprland environment
- Not all components are required - feel free to pick and choose what you need

## License

Feel free to use, modify, and share these dotfiles!

---

**Enjoy your rice!**
