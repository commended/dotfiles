#!/usr/bin/env bash

# Theme Switcher Script
# Uses rofi to switch between themes with coordinated Waybar and Rofi colors

# ============================================================================
# Configuration
# ============================================================================

WALLPAPER_DIR="~/Pictures/wallpapers"
WAYBAR_COLORS="/home/aug/.config/waybar/colors.css"
ROFI_CONFIG="$HOME/.config/rofi/themeswitcher/themeswitcher.rasi"
ROFI_WALLPAPER_CONFIG="$HOME/.config/rofi/wallpaper.rasi"
CACHE_DIR="$HOME/.cache/themeswitcher"
THUMBNAIL_DIR="$CACHE_DIR/thumbnails"

# Create cache directories if they don't exist
mkdir -p "$THUMBNAIL_DIR"

# ============================================================================
# Theme Definitions
# ============================================================================

declare -A THEME_DARK=(
    [name]="Dark"
    [wallpaper_dir]="$WALLPAPER_DIR/dark"
    [theme_id]="dark"
    [pywal_bg]="#0a0a0a"
    [pywal_fg]="#e0e0e0"
    [pywal_cursor]="#e0e0e0"
    [pywal_light]=""
    [color0]="#0a0a0a" [color1]="#1a1a1a" [color2]="#2a2a2a" [color3]="#3a3a3a"
    [color4]="#4a4a4a" [color5]="#5a5a5a" [color6]="#6a6a6a" [color7]="#e0e0e0"
    [color8]="#7a7a7a" [color9]="#8a8a8a" [color10]="#9a9a9a" [color11]="#aaaaaa"
    [color12]="#bababa" [color13]="#cacaca" [color14]="#dadada" [color15]="#ffffff"
    [waybar_bg]="#0a0a0a"
    [waybar_fg]="#e0e0e0"
    [waybar_surface0]="#1a1a1a"
    [waybar_surface1]="#2a2a2a"
    [waybar_surface2]="#3a3a3a"
    [waybar_accent]="#6a6a6a"
    [waybar_border]="#4a4a4a"
    [rofi_bg]="#0a0a0aff"
    [rofi_bg_alt]="#1a1a1aff"
    [rofi_fg]="#e0e0e0ff"
    [rofi_selected]="#6a6a6aff"
    [rofi_active]="#2a2a2aff"
    [rofi_urgent]="#4a4a4aff"
    [rofi_border]="#4a4a4aff"
)

declare -A THEME_LIGHT=(
    [name]="Light"
    [wallpaper_dir]="$WALLPAPER_DIR/light"
    [theme_id]="light"
    [pywal_bg]="#ffffff"
    [pywal_fg]="#000000"
    [pywal_cursor]="#000000"
    [pywal_light]="-l"
    [color0]="#000000" [color1]="#1a1a1a" [color2]="#2a2a2a" [color3]="#2a2a2a"
    [color4]="#3a3a3a" [color5]="#4a4a4a" [color6]="#5a5a5a" [color7]="#e0e0e0"
    [color8]="#6a6a6a" [color9]="#7a7a7a" [color10]="#8a8a8a" [color11]="#9a9a9a"
    [color12]="#aaaaaa" [color13]="#bababa" [color14]="#cacaca" [color15]="#000000"
    [waybar_bg]="#ffffff"
    [waybar_fg]="#000000"
    [waybar_surface0]="#f5f5f5"
    [waybar_surface1]="#e5e5e5"
    [waybar_surface2]="#d5d5d5"
    [waybar_accent]="#2a2a2a"
    [waybar_border]="#2a2a2a"
    [rofi_bg]="#ffffffff"
    [rofi_bg_alt]="#f5f5f5ff"
    [rofi_fg]="#000000ff"
    [rofi_selected]="#2a2a2aff"
    [rofi_active]="#e5e5e5ff"
    [rofi_urgent]="#d5d5d5ff"
    [rofi_border]="#2a2a2aff"
)

declare -A THEME_GRUVBOX=(
    [name]="Gruvbox"
    [wallpaper_dir]="$WALLPAPER_DIR/gruvbox"
    [theme_id]="gruvbox"
    [pywal_bg]="#282828"
    [pywal_fg]="#ebdbb2"
    [pywal_cursor]="#ebdbb2"
    [pywal_light]=""
    [color0]="#282828" [color1]="#cc241d" [color2]="#98971a" [color3]="#d5c4a1"
    [color4]="#458588" [color5]="#b16286" [color6]="#689d6a" [color7]="#a89984"
    [color8]="#928374" [color9]="#fb4934" [color10]="#b8bb26" [color11]="#ebdbb2"
    [color12]="#83a598" [color13]="#d3869b" [color14]="#8ec07c" [color15]="#ebdbb2"
    [waybar_bg]="#282828"
    [waybar_fg]="#ebdbb2"
    [waybar_surface0]="#3c3836"
    [waybar_surface1]="#504945"
    [waybar_surface2]="#665c54"
    [waybar_accent]="#d5c4a1"
    [waybar_border]="#bdae93"
    [rofi_bg]="#282828ff"
    [rofi_bg_alt]="#3c3836ff"
    [rofi_fg]="#ebdbb2ff"
    [rofi_selected]="#d5c4a1ff"
    [rofi_active]="#504945ff"
    [rofi_urgent]="#665c54ff"
    [rofi_border]="#bdae93ff"
)

declare -A THEME_GRUVBOX_DARK=(
    [name]="Gruvbox Dark"
    [wallpaper_dir]="$WALLPAPER_DIR/gruvbox-dark"
    [theme_id]="gruvbox-dark"
    [pywal_bg]="#0d0e0f"
    [pywal_fg]="#bdae93"
    [pywal_cursor]="#bdae93"
    [pywal_light]=""
    [color0]="#0d0e0f" [color1]="#cc241d" [color2]="#98971a" [color3]="#a89984"
    [color4]="#458588" [color5]="#b16286" [color6]="#689d6a" [color7]="#a89984"
    [color8]="#504945" [color9]="#fb4934" [color10]="#b8bb26" [color11]="#d5c4a1"
    [color12]="#83a598" [color13]="#d3869b" [color14]="#8ec07c" [color15]="#bdae93"
    [waybar_bg]="#0d0e0f"
    [waybar_fg]="#bdae93"
    [waybar_surface0]="#1d2021"
    [waybar_surface1]="#282828"
    [waybar_surface2]="#3c3836"
    [waybar_accent]="#a89984"
    [waybar_border]="#504945"
    [rofi_bg]="#0d0e0fff"
    [rofi_bg_alt]="#1d2021ff"
    [rofi_fg]="#bdae93ff"
    [rofi_selected]="#a89984ff"
    [rofi_active]="#282828ff"
    [rofi_urgent]="#3c3836ff"
    [rofi_border]="#504945ff"
)

declare -A THEME_NORD=(
    [name]="Nord"
    [wallpaper_dir]="$WALLPAPER_DIR/nord"
    [theme_id]="nord"
    [pywal_bg]="#2e3440"
    [pywal_fg]="#d8dee9"
    [pywal_cursor]="#d8dee9"
    [pywal_light]=""
    [color0]="#3b4252" [color1]="#bf616a" [color2]="#a3be8c" [color3]="#88c0d0"
    [color4]="#81a1c1" [color5]="#b48ead" [color6]="#88c0d0" [color7]="#e5e9f0"
    [color8]="#4c566a" [color9]="#bf616a" [color10]="#a3be8c" [color11]="#8fbcbb"
    [color12]="#81a1c1" [color13]="#b48ead" [color14]="#8fbcbb" [color15]="#eceff4"
    [waybar_bg]="#2e3440"
    [waybar_fg]="#d8dee9"
    [waybar_surface0]="#3b4252"
    [waybar_surface1]="#434c5e"
    [waybar_surface2]="#4c566a"
    [waybar_accent]="#88c0d0"
    [waybar_border]="#5e81ac"
    [rofi_bg]="#2e3440ff"
    [rofi_bg_alt]="#3b4252ff"
    [rofi_fg]="#d8dee9ff"
    [rofi_selected]="#88c0d0ff"
    [rofi_active]="#434c5eff"
    [rofi_urgent]="#4c566aff"
    [rofi_border]="#5e81acff"
)

declare -A THEME_SAKURA=(
    [name]="Sakura"
    [wallpaper_dir]="$WALLPAPER_DIR/sakura"
    [theme_id]="sakura"
    [pywal_bg]="#2d1520"
    [pywal_fg]="#ffc0d9"
    [pywal_cursor]="#ff6b9d"
    [pywal_light]=""
    [color0]="#2d1520" [color1]="#ff6b9d" [color2]="#ff8fab" [color3]="#ffa3c4"
    [color4]="#ff5c8d" [color5]="#ff4d7d" [color6]="#ff94b8" [color7]="#ffc0d9"
    [color8]="#4a2533" [color9]="#ff3d6d" [color10]="#ff7fa3" [color11]="#ffd4e8"
    [color12]="#ff99b8" [color13]="#ff2d5d" [color14]="#ff85a8" [color15]="#ffe8f0"
    [waybar_bg]="#2d1520"
    [waybar_fg]="#ffc0d9"
    [waybar_surface0]="#3d1f2d"
    [waybar_surface1]="#4d2939"
    [waybar_surface2]="#5d3346"
    [waybar_accent]="#ff6b9d"
    [waybar_border]="#ff5c8d"
    [rofi_bg]="#2d1520ff"
    [rofi_bg_alt]="#3d1f2dff"
    [rofi_fg]="#ffc0d9ff"
    [rofi_selected]="#ff6b9dff"
    [rofi_active]="#4d2939ff"
    [rofi_urgent]="#5d3346ff"
    [rofi_border]="#ff5c8dff"
)

# ============================================================================
# Helper Functions
# ============================================================================

# ============================================================================
# Helper Functions
# ============================================================================

# Function to generate thumbnail
generate_thumbnail() {
    local image="$1"
    local thumbnail="$THUMBNAIL_DIR/$(basename "${image%.*}").png"
    [[ -f "$thumbnail" ]] || convert "$image" -resize 500x500^ -gravity center -extent 500x500 -strip -quality 85 "$thumbnail" 2>/dev/null
}

# Function to just change wallpaper without reloading theme
change_wallpaper_only() {
    local wallpaper="$1"
    swww img "$wallpaper" --transition-type grow --transition-duration 1 --transition-fps 60
    notify-send "Theme Switcher" "Wallpaper updated!"
}

# Generic function to apply any theme
apply_theme() {
    local -n theme=$1
    local wallpaper="$2"
    
    # Set wallpaper
    swww img "$wallpaper" --transition-type grow --transition-duration 1 --transition-fps 60
    sleep 1
    
    # Generate pywal colors JSON
    cat > "/tmp/theme_colors.json" <<EOF
{
    "special": {
        "background": "${theme[pywal_bg]}",
        "foreground": "${theme[pywal_fg]}",
        "cursor": "${theme[pywal_cursor]}"
    },
    "colors": {
        "color0": "${theme[color0]}",
        "color1": "${theme[color1]}",
        "color2": "${theme[color2]}",
        "color3": "${theme[color3]}",
        "color4": "${theme[color4]}",
        "color5": "${theme[color5]}",
        "color6": "${theme[color6]}",
        "color7": "${theme[color7]}",
        "color8": "${theme[color8]}",
        "color9": "${theme[color9]}",
        "color10": "${theme[color10]}",
        "color11": "${theme[color11]}",
        "color12": "${theme[color12]}",
        "color13": "${theme[color13]}",
        "color14": "${theme[color14]}",
        "color15": "${theme[color15]}"
    }
}
EOF
    
    # Apply pywal theme
    wal --theme /tmp/theme_colors.json -n ${theme[pywal_light]}
    
    # Generate Waybar colors
    cat > "$WAYBAR_COLORS" <<EOF
/* ${theme[name]} Theme Active */
@define-color background ${theme[waybar_bg]};
@define-color foreground ${theme[waybar_fg]};
@define-color surface0 ${theme[waybar_surface0]};
@define-color surface1 ${theme[waybar_surface1]};
@define-color surface2 ${theme[waybar_surface2]};
@define-color accent ${theme[waybar_accent]};
@define-color border ${theme[waybar_border]};
EOF
    
    # Generate Rofi colors for theme switcher and other menus
    cat > "$HOME/.config/rofi/colors/updating.rasi" <<EOF
* {
    background:     ${theme[rofi_bg]};
    background-alt: ${theme[rofi_bg_alt]};
    foreground:     ${theme[rofi_fg]};
    selected:       ${theme[rofi_selected]};
    active:         ${theme[rofi_active]};
    urgent:         ${theme[rofi_urgent]};
    border:         ${theme[rofi_border]};
}
EOF
    
    # Reload applications
    pkill -SIGUSR2 waybar &
    
    # Send notification after all changes applied
    notify-send "Theme Switcher" "Theme set: ${theme[name]}"
    echo "${theme[name]} theme applied with wallpaper: $(basename "$wallpaper")"
}

# Wrapper functions for compatibility
apply_dark_theme() {
    apply_theme THEME_DARK "$1"
}

apply_light_theme() {
    apply_theme THEME_LIGHT "$1"
}

apply_gruvbox_theme() {
    apply_theme THEME_GRUVBOX "$1"
}

apply_gruvbox_dark_theme() {
    apply_theme THEME_GRUVBOX_DARK "$1"
}

apply_nord_theme() {
    apply_theme THEME_NORD "$1"
}

apply_sakura_theme() {
    apply_theme THEME_SAKURA "$1"
}

# ============================================================================
# Wallpaper Selection Functions
# ============================================================================

# Generic wallpaper selection function
select_wallpaper() {
    local -n theme=$1
    local -A wallpaper_map
    local entries=""
    
    # Check if wallpaper directory exists
    if [[ ! -d "${theme[wallpaper_dir]}" ]]; then
        notify-send "Theme Switcher" "Wallpaper directory not found: ${theme[wallpaper_dir]}"
        return 1
    fi
    
    # Scan directory for image files
    while IFS= read -r -d '' image; do
        local name=$(basename "${image%.*}")
        generate_thumbnail "$image"
        local thumbnail="$THUMBNAIL_DIR/${name}.png"
        [[ -f "$thumbnail" ]] && {
            wallpaper_map["$name"]="$image"
            entries+="${name}\0icon\x1f${thumbnail}\n"
        }
    done < <(find "${theme[wallpaper_dir]}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | sort -z)
    
    # Check if any wallpapers were found
    if [[ -z "$entries" ]]; then
        notify-send "Theme Switcher" "No wallpapers found in ${theme[wallpaper_dir]}"
        return 1
    fi
    
    selected=$(printf "$entries" | rofi -dmenu -i -p "${theme[name]}" -show-icons -theme "$ROFI_WALLPAPER_CONFIG" 2>/dev/null)
    
    if [[ -n "$selected" ]] && [[ -n "${wallpaper_map[$selected]}" ]]; then
        if [[ -f "$CACHE_DIR/current_theme" ]] && [[ "$(cat "$CACHE_DIR/current_theme")" == "${theme[theme_id]}" ]]; then
            change_wallpaper_only "${wallpaper_map[$selected]}"
        else
            apply_theme "$1" "${wallpaper_map[$selected]}"
            echo "${theme[theme_id]}" > "$CACHE_DIR/current_theme"
        fi
    fi
}

# Wrapper functions for backward compatibility
select_dark_wallpaper() {
    select_wallpaper THEME_DARK
}

select_light_wallpaper() {
    select_wallpaper THEME_LIGHT
}

select_gruvbox_wallpaper() {
    select_wallpaper THEME_GRUVBOX
}

select_gruvbox_dark_wallpaper() {
    select_wallpaper THEME_GRUVBOX_DARK
}

select_nord_wallpaper() {
    select_wallpaper THEME_NORD
}

select_sakura_wallpaper() {
    select_wallpaper THEME_SAKURA
}

# ============================================================================
# Menu Functions
# ============================================================================

# Function to show gruvbox submenu
gruvbox_menu() {
  selected=$(echo -e "Gruvbox\nGruvbox Dark" | rofi -dmenu -i -p "Gruvbox" -theme "$ROFI_CONFIG")

  case "$selected" in
  "Gruvbox") select_gruvbox_wallpaper ;;
  "Gruvbox Dark") select_gruvbox_dark_wallpaper ;;
  esac
}

# Main menu
main_menu() {
  selected=$(echo -e "Dark\nLight\nGruvbox\nNord\nSakura" | rofi -dmenu -i -p "Theme" -theme "$ROFI_CONFIG")

  case "$selected" in
  "Dark") select_dark_wallpaper ;;
  "Light") select_light_wallpaper ;;
  "Gruvbox") gruvbox_menu ;;
  "Nord") select_nord_wallpaper ;;
  "Sakura") select_sakura_wallpaper ;;
  esac
}

main_menu
