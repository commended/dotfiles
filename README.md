# My Dotfiles

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

## Notes

- Some scripts may reference absolute paths - update these to match your system
- Not all components are required, feel free to pick and choose what you need

