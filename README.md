# My Dotfiles

## Quick Start

### Automated Installation

The easiest way to install these dotfiles is using the interactive installation script:

```bash
git clone https://github.com/commended/dotfiles.git
cd dotfiles
./install.sh
```

The install script provides:
- 🎨 **ASCII Art Interface** - Beautiful terminal UI with progress indicators
- ✅ **Interactive Menu** - Select which components to install
- 📦 **Automatic Backups** - Backs up existing configurations
- 🔧 **Path Fixing** - Automatically fixes absolute paths for your system
- 📊 **Progress Tracking** - Visual progress bars and status updates
- 🎯 **Selective Installation** - Choose core components or install everything

#### Installation Options:

**Core Components:**
- Hyprland Configuration
- Rofi Configuration  
- Waybar Configuration
- Themes & Wallpapers

**Additional Components:**
- Kitty Terminal
- Fastfetch
- Neovim Configuration
- Misc (Zsh, Yazi, Starship, etc.)

The installer will automatically:
- Create necessary directories
- Fix absolute paths in configuration files
- Set correct permissions on scripts
- Install wallpapers to `~/.local/share/wallpapers`
- Notify you of all changes made

### Manual Installation

If you prefer to install manually, copy the desired configuration directories to `~/.config/`:

```bash
cp -r hypr ~/.config/
cp -r rofi ~/.config/
cp -r waybar ~/.config/
# ... etc
```

**Note:** Manual installation requires fixing absolute paths yourself. See the Troubleshooting section below.

## Showcase

### Screenshots

<table border="0">
  <tr>
    <td><img src="https://github.com/commended/dotfiles/blob/c73d4465062fb28ad8d34a846d6267eb0609096b/misc/showcase/floating.png" width="900"/></td>
    <td><img src="https://github.com/commended/dotfiles/blob/c73d4465062fb28ad8d34a846d6267eb0609096b/misc/showcase/whitenvim.png" width="900"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/commended/dotfiles/blob/c73d4465062fb28ad8d34a846d6267eb0609096b/misc/showcase/browser.png" width="900"/></td>
    <td><img src="https://github.com/commended/dotfiles/blob/c73d4465062fb28ad8d34a846d6267eb0609096b/misc/showcase/tiled.png" width="900"/></td>
  </tr>
</table>

### Themes

<details>
<summary>Dark</summary>

![Alt text](https://github.com/commended/dotfiles/blob/c73d4465062fb28ad8d34a846d6267eb0609096b/misc/showcase/themes/dark.png)

</details>
<details>
<summary>Light</summary>

![Alt text](https://github.com/commended/dotfiles/blob/c73d4465062fb28ad8d34a846d6267eb0609096b/misc/showcase/themes/light.png)

</details>
<details>
<summary>Gruvbox</summary>

![Alt text](https://github.com/commended/dotfiles/blob/c73d4465062fb28ad8d34a846d6267eb0609096b/misc/showcase/themes/gruvbox.png)

</details>
<details>
<summary>Gruvbox Dark</summary>

![Alt text](https://github.com/commended/dotfiles/blob/c73d4465062fb28ad8d34a846d6267eb0609096b/misc/showcase/themes/gruvdark.png)

</details>
<details>
<summary>Nord</summary>

![Alt text](https://github.com/commended/dotfiles/blob/c73d4465062fb28ad8d34a846d6267eb0609096b/misc/showcase/themes/nord.png)

</details>
<details>
<summary>Sakura</summary>

![Alt text](https://github.com/commended/dotfiles/blob/c73d4465062fb28ad8d34a846d6267eb0609096b/misc/showcase/themes/sakura.png)

</details>




## What's Included

- **hypr** - Main window manager configuration aswell as hyprlock configuration
- **waybar** - Statusbar
- **kitty** - terminal
- **rofi** - theme switcher/application launcher/powermenu
- **fastfetch** - System information display
- **nvim** - plugins
- **misc** - yazi, rmpc, zsh, starship, and kotofetch configurations aswell as my wallpapers

## Prerequisites

- hyprland
- waybar
- kitty
- rofi
- fastfetch
- zsh
- starship
- nvim
- rmpc
- yazi
- cargo
- swww
- grim
- slurp
- brightnessctl
- wireplumber
- pywal
- a nerd font

## Customization

### Fonts
- Ensure a Nerd Font is installed for proper icon display
- Update font settings in:
  - Kitty: `~/.config/kitty/kitty.conf`
  - Waybar: `~/.config/waybar/config`

### Key Bindings
- Main keybindings are in `~/.config/hypr/config/binds.conf`
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

**Absolute Paths (Manual Installation Only)**

If you installed manually (without using `install.sh`), you'll need to fix these absolute paths:

1. **Waybar** (`~/.config/waybar/style.css`):
   - Change `/home/aug/.cache/wal/colors-waybar.css` to `$HOME/.cache/wal/colors-waybar.css`

2. **Hyprland** (`~/.config/hypr/config/binds.conf`):
   - Change `/home/aug/Pictures/showcases/` to your preferred screenshot directory

3. **Rofi Theme Switcher** (`~/.config/rofi/themeswitcher/themeswitcher.sh`):
   - Set `WALLPAPER_DIR` to your wallpaper directory (e.g., `$HOME/.local/share/wallpapers`)
   - Set `WAYBAR_COLORS` to `$HOME/.cache/wal/colors-waybar.css`

4. **RMPC** (`~/.config/rmpc/mpd.conf`):
   - Change `/home/aug/media/music` to your music directory

**Note:** The `install.sh` script automatically fixes all these paths for you!

## Notes

- The install script automatically handles all path configurations
- Not all components are required, feel free to pick and choose what you need
- Backups are created by default when using the install script

