# ricing

My Wayland/Hyprland dotfiles – A complete rice configuration for a beautiful Linux desktop experience.


<div align="center"><table><tr>Showcase</tr><tr><td>
<img src="https://github.com/commended/ricing/blob/cf00082f5498d72db5d82c6f6e15dea9497d088e/misc/showcase/floating.png"/></td><td>
<img src="https://github.com/commended/ricing/blob/cf00082f5498d72db5d82c6f6e15dea9497d088e/misc/showcase/walls.png"/></td><td>
<img src="https://github.com/commended/ricing/blob/cf00082f5498d72db5d82c6f6e15dea9497d088e/misc/showcase/windows.png"/></td></tr></table></div>


## What's Included
This dotfiles repository includes configurations for:

- **hyprland** - Main window manager configuration
- **waybar** - Sleek status bar with custom modules
- **kitty** - Fast GPU-accelerated terminal emulator
- **rofi** - Wallpaper selector/application launcher/powermenu
- **fastfetch** - System information display
- **zsh** - Enhanced shell configuration
- **starship** - Beautiful shell prompt
- **nvim** - LazyVim text editor setup
- **rmpc** - MPD client configuration
- **yazi** - Terminal file manager

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
