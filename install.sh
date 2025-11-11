#!/usr/bin/env bash

# ============================================================================
# Dotfiles Installer
# ============================================================================
# This script installs Hyprland configuration, Rofi, Waybar, and themes
# with interactive options and progress tracking
# ============================================================================

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get current user and home directory
CURRENT_USER="${USER:-$(whoami)}"
USER_HOME="${HOME:-/home/$CURRENT_USER}"

# Installation flags (will be set by user menu)
INSTALL_HYPRLAND=false
INSTALL_ROFI=false
INSTALL_WAYBAR=false
INSTALL_THEMES=false
INSTALL_KITTY=false
INSTALL_FASTFETCH=false
INSTALL_NVIM=false
INSTALL_MISC=false
CREATE_BACKUP=true

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$USER_HOME/.config"
BACKUP_DIR="$USER_HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# ============================================================================
# ASCII Art Banner
# ============================================================================
show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
    ____        __  _____ __         
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  ) 
/_____/\____/\__/_/ /_/_/\___/____/  
                                      
    ___           __        ____         
   /   |  _______/ /_      /  _/___  ____
  / /| | / ___/ __ \      / // __ \/ __ \
 / ___ |/ /  / /_/ /    _/ // / / / /_/ /
/_/  |_/_/   \____/    /___/_/ /_/\____/ 
                                          
EOF
    echo -e "${NC}"
    echo -e "${BOLD}Hyprland Dotfiles Installer${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============================================================================
# Helper Functions
# ============================================================================

# Print colored message
print_msg() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Print step header
print_step() {
    echo ""
    echo -e "${BOLD}${MAGENTA}▶ $*${NC}"
}

# Print success message
print_success() {
    echo -e "${GREEN}✓ $*${NC}"
}

# Print warning message
print_warning() {
    echo -e "${YELLOW}⚠ $*${NC}"
}

# Print error message
print_error() {
    echo -e "${RED}✗ $*${NC}"
}

# Print info message
print_info() {
    echo -e "${BLUE}ℹ $*${NC}"
}

# Show progress bar
show_progress() {
    local current=$1
    local total=$2
    local task=$3
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] ${percent}%% ${NC}- ${task}   "
}

# Complete progress bar
complete_progress() {
    echo ""
    print_success "Installation step completed!"
}

# ============================================================================
# Dependency Checking
# ============================================================================

check_dependencies() {
    print_step "Checking system dependencies"
    
    local missing_deps=()
    local optional_missing=()
    
    # Required dependencies
    local required_deps=("git")
    
    # Optional dependencies based on what user wants to install
    local optional_deps=()
    
    if [ "$INSTALL_HYPRLAND" = true ]; then
        optional_deps+=("hyprland" "hyprctl")
    fi
    
    if [ "$INSTALL_WAYBAR" = true ]; then
        optional_deps+=("waybar")
    fi
    
    if [ "$INSTALL_ROFI" = true ]; then
        optional_deps+=("rofi")
    fi
    
    if [ "$INSTALL_KITTY" = true ]; then
        optional_deps+=("kitty")
    fi
    
    if [ "$INSTALL_THEMES" = true ]; then
        optional_deps+=("swww" "wal" "convert")
    fi
    
    # Check required dependencies
    for dep in "${required_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    # Check optional dependencies
    for dep in "${optional_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            optional_missing+=("$dep")
        fi
    done
    
    # Report missing dependencies
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install them before continuing."
        return 1
    fi
    
    if [ ${#optional_missing[@]} -gt 0 ]; then
        print_warning "Missing optional dependencies: ${optional_missing[*]}"
        print_info "Some features may not work without these."
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    print_success "Dependency check completed"
    return 0
}

# ============================================================================
# Backup Functions
# ============================================================================

create_backup() {
    if [ "$CREATE_BACKUP" = false ]; then
        return 0
    fi
    
    print_step "Creating backup of existing configurations"
    
    local backed_up=0
    local configs_to_backup=()
    
    [ "$INSTALL_HYPRLAND" = true ] && configs_to_backup+=("hypr")
    [ "$INSTALL_ROFI" = true ] && configs_to_backup+=("rofi")
    [ "$INSTALL_WAYBAR" = true ] && configs_to_backup+=("waybar")
    [ "$INSTALL_KITTY" = true ] && configs_to_backup+=("kitty")
    [ "$INSTALL_FASTFETCH" = true ] && configs_to_backup+=("fastfetch")
    [ "$INSTALL_NVIM" = true ] && configs_to_backup+=("nvim")
    
    for config in "${configs_to_backup[@]}"; do
        if [ -d "$CONFIG_DIR/$config" ] || [ -f "$CONFIG_DIR/$config" ]; then
            mkdir -p "$BACKUP_DIR"
            cp -r "$CONFIG_DIR/$config" "$BACKUP_DIR/" 2>/dev/null || true
            print_info "Backed up: $config"
            ((backed_up++))
        fi
    done
    
    if [ $backed_up -gt 0 ]; then
        print_success "Backup created at: $BACKUP_DIR"
    else
        print_info "No existing configurations found to backup"
    fi
}

# ============================================================================
# Path Fixing Functions
# ============================================================================

fix_absolute_paths() {
    print_step "Fixing absolute paths in configurations"
    
    local fixes_made=0
    
    # Fix waybar style.css
    if [ "$INSTALL_WAYBAR" = true ] && [ -f "$CONFIG_DIR/waybar/style.css" ]; then
        local waybar_colors_path="$USER_HOME/.cache/wal/colors-waybar.css"
        if grep -q "/home/aug/.cache/wal/colors-waybar.css" "$CONFIG_DIR/waybar/style.css"; then
            sed -i "s|/home/aug/.cache/wal/colors-waybar.css|$waybar_colors_path|g" "$CONFIG_DIR/waybar/style.css"
            print_info "Fixed: waybar/style.css - Updated path to $waybar_colors_path"
            ((fixes_made++))
        fi
    fi
    
    # Fix hypr binds.conf
    if [ "$INSTALL_HYPRLAND" = true ] && [ -f "$CONFIG_DIR/hypr/config/binds.conf" ]; then
        local screenshots_dir="$USER_HOME/Pictures/screenshots"
        mkdir -p "$screenshots_dir"
        if grep -q "/home/aug/Pictures/showcases/" "$CONFIG_DIR/hypr/config/binds.conf"; then
            sed -i "s|/home/aug/Pictures/showcases/|$screenshots_dir/|g" "$CONFIG_DIR/hypr/config/binds.conf"
            print_info "Fixed: hypr/config/binds.conf - Updated screenshots path to $screenshots_dir"
            ((fixes_made++))
        fi
    fi
    
    # Fix themeswitcher script
    if [ "$INSTALL_ROFI" = true ] && [ -f "$CONFIG_DIR/rofi/themeswitcher/themeswitcher.sh" ]; then
        local wallpaper_dir="$SCRIPT_DIR/misc/walls"
        local waybar_colors_file="$USER_HOME/.cache/wal/colors-waybar.css"
        
        if grep -q '<enter wallpaper directory here>' "$CONFIG_DIR/rofi/themeswitcher/themeswitcher.sh"; then
            sed -i "s|WALLPAPER_DIR=\"<enter wallpaper directory here>\"|WALLPAPER_DIR=\"$wallpaper_dir\"|g" "$CONFIG_DIR/rofi/themeswitcher/themeswitcher.sh"
            print_info "Fixed: rofi/themeswitcher/themeswitcher.sh - Set WALLPAPER_DIR to $wallpaper_dir"
            ((fixes_made++))
        fi
        
        if grep -q 'WAYBAR_COLORS="<enter>"' "$CONFIG_DIR/rofi/themeswitcher/themeswitcher.sh"; then
            sed -i "s|WAYBAR_COLORS=\"<enter>\"|WAYBAR_COLORS=\"$waybar_colors_file\"|g" "$CONFIG_DIR/rofi/themeswitcher/themeswitcher.sh"
            print_info "Fixed: rofi/themeswitcher/themeswitcher.sh - Set WAYBAR_COLORS to $waybar_colors_file"
            ((fixes_made++))
        fi
        
        # Make the script executable
        chmod +x "$CONFIG_DIR/rofi/themeswitcher/themeswitcher.sh"
    fi
    
    # Fix MPD config if misc is installed
    if [ "$INSTALL_MISC" = true ] && [ -f "$CONFIG_DIR/rmpc/mpd.conf" ]; then
        local music_dir="$USER_HOME/Music"
        mkdir -p "$music_dir"
        if grep -q "/home/aug/media/music" "$CONFIG_DIR/rmpc/mpd.conf"; then
            sed -i "s|/home/aug/media/music|$music_dir|g" "$CONFIG_DIR/rmpc/mpd.conf"
            print_info "Fixed: rmpc/mpd.conf - Updated music directory to $music_dir"
            ((fixes_made++))
        fi
    fi
    
    # Make rofi scripts executable
    if [ "$INSTALL_ROFI" = true ]; then
        find "$CONFIG_DIR/rofi" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    fi
    
    if [ $fixes_made -gt 0 ]; then
        print_success "Fixed $fixes_made absolute path(s)"
    else
        print_info "No absolute paths needed fixing"
    fi
}

# ============================================================================
# Installation Functions
# ============================================================================

install_hyprland_config() {
    print_step "Installing Hyprland configuration"
    
    show_progress 1 3 "Copying Hyprland config files"
    mkdir -p "$CONFIG_DIR/hypr"
    cp -r "$SCRIPT_DIR/hypr/"* "$CONFIG_DIR/hypr/"
    
    show_progress 2 3 "Setting up Hyprland directories"
    mkdir -p "$CONFIG_DIR/hypr/images"
    mkdir -p "$USER_HOME/Pictures/screenshots"
    
    show_progress 3 3 "Finalizing Hyprland installation"
    complete_progress
}

install_rofi_config() {
    print_step "Installing Rofi configuration"
    
    show_progress 1 3 "Copying Rofi config files"
    mkdir -p "$CONFIG_DIR/rofi"
    cp -r "$SCRIPT_DIR/rofi/"* "$CONFIG_DIR/rofi/"
    
    show_progress 2 3 "Creating Rofi directories"
    mkdir -p "$CONFIG_DIR/rofi/colors"
    mkdir -p "$USER_HOME/.cache/themeswitcher/thumbnails"
    
    show_progress 3 3 "Setting script permissions"
    find "$CONFIG_DIR/rofi" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    complete_progress
}

install_waybar_config() {
    print_step "Installing Waybar configuration"
    
    show_progress 1 2 "Copying Waybar config files"
    mkdir -p "$CONFIG_DIR/waybar"
    cp -r "$SCRIPT_DIR/waybar/"* "$CONFIG_DIR/waybar/"
    
    show_progress 2 2 "Creating cache directories"
    mkdir -p "$USER_HOME/.cache/wal"
    complete_progress
}

install_kitty_config() {
    print_step "Installing Kitty configuration"
    
    show_progress 1 1 "Copying Kitty config files"
    mkdir -p "$CONFIG_DIR/kitty"
    cp -r "$SCRIPT_DIR/kitty/"* "$CONFIG_DIR/kitty/"
    complete_progress
}

install_fastfetch_config() {
    print_step "Installing Fastfetch configuration"
    
    show_progress 1 1 "Copying Fastfetch config files"
    mkdir -p "$CONFIG_DIR/fastfetch"
    cp -r "$SCRIPT_DIR/fastfetch/"* "$CONFIG_DIR/fastfetch/"
    complete_progress
}

install_nvim_config() {
    print_step "Installing Neovim configuration"
    
    show_progress 1 1 "Copying Neovim config files"
    mkdir -p "$CONFIG_DIR/nvim"
    cp -r "$SCRIPT_DIR/nvim/"* "$CONFIG_DIR/nvim/"
    complete_progress
}

install_misc_configs() {
    print_step "Installing misc configurations"
    
    show_progress 1 5 "Installing Yazi config"
    if [ -d "$SCRIPT_DIR/misc/yazi" ]; then
        mkdir -p "$CONFIG_DIR/yazi"
        cp -r "$SCRIPT_DIR/misc/yazi/"* "$CONFIG_DIR/yazi/"
    fi
    
    show_progress 2 5 "Installing RMPC config"
    if [ -d "$SCRIPT_DIR/misc/rmpc" ]; then
        mkdir -p "$CONFIG_DIR/rmpc"
        cp -r "$SCRIPT_DIR/misc/rmpc/"* "$CONFIG_DIR/rmpc/"
    fi
    
    show_progress 3 5 "Installing shell configs"
    if [ -d "$SCRIPT_DIR/misc/shell" ]; then
        cp -r "$SCRIPT_DIR/misc/shell/.zshrc" "$USER_HOME/" 2>/dev/null || true
    fi
    
    show_progress 4 5 "Installing Starship config"
    if [ -d "$SCRIPT_DIR/misc/starship" ]; then
        mkdir -p "$CONFIG_DIR"
        cp -r "$SCRIPT_DIR/misc/starship/starship.toml" "$CONFIG_DIR/" 2>/dev/null || true
    fi
    
    show_progress 5 5 "Installing Kotofetch config"
    if [ -d "$SCRIPT_DIR/misc/kotofetch" ]; then
        mkdir -p "$CONFIG_DIR/kotofetch"
        cp -r "$SCRIPT_DIR/misc/kotofetch/"* "$CONFIG_DIR/kotofetch/" 2>/dev/null || true
    fi
    
    complete_progress
}

install_themes_and_wallpapers() {
    print_step "Installing themes and wallpapers"
    
    show_progress 1 2 "Copying wallpapers"
    local walls_dest="$USER_HOME/.local/share/wallpapers"
    mkdir -p "$walls_dest"
    
    if [ -d "$SCRIPT_DIR/misc/walls" ]; then
        cp -r "$SCRIPT_DIR/misc/walls/"* "$walls_dest/"
        
        # Update themeswitcher to point to new wallpaper location
        if [ -f "$CONFIG_DIR/rofi/themeswitcher/themeswitcher.sh" ]; then
            sed -i "s|WALLPAPER_DIR=\".*misc/walls\"|WALLPAPER_DIR=\"$walls_dest\"|g" "$CONFIG_DIR/rofi/themeswitcher/themeswitcher.sh" || true
        fi
    fi
    
    show_progress 2 2 "Setting up theme files"
    mkdir -p "$USER_HOME/.cache/wal"
    complete_progress
}

# ============================================================================
# Menu Functions
# ============================================================================

show_menu() {
    clear
    show_banner
    
    echo -e "${BOLD}Installation Options${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Core Components:${NC}"
    echo -e "  1) Hyprland Configuration    $([ "$INSTALL_HYPRLAND" = true ] && echo -e "${GREEN}[✓]${NC}" || echo -e "${RED}[ ]${NC}")"
    echo -e "  2) Rofi Configuration        $([ "$INSTALL_ROFI" = true ] && echo -e "${GREEN}[✓]${NC}" || echo -e "${RED}[ ]${NC}")"
    echo -e "  3) Waybar Configuration      $([ "$INSTALL_WAYBAR" = true ] && echo -e "${GREEN}[✓]${NC}" || echo -e "${RED}[ ]${NC}")"
    echo -e "  4) Themes & Wallpapers       $([ "$INSTALL_THEMES" = true ] && echo -e "${GREEN}[✓]${NC}" || echo -e "${RED}[ ]${NC}")"
    echo ""
    echo -e "${CYAN}Additional Components:${NC}"
    echo -e "  5) Kitty Terminal            $([ "$INSTALL_KITTY" = true ] && echo -e "${GREEN}[✓]${NC}" || echo -e "${RED}[ ]${NC}")"
    echo -e "  6) Fastfetch                 $([ "$INSTALL_FASTFETCH" = true ] && echo -e "${GREEN}[✓]${NC}" || echo -e "${RED}[ ]${NC}")"
    echo -e "  7) Neovim Configuration      $([ "$INSTALL_NVIM" = true ] && echo -e "${GREEN}[✓]${NC}" || echo -e "${RED}[ ]${NC}")"
    echo -e "  8) Misc (Zsh, Yazi, etc.)    $([ "$INSTALL_MISC" = true ] && echo -e "${GREEN}[✓]${NC}" || echo -e "${RED}[ ]${NC}")"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo -e "  9) Create Backup             $([ "$CREATE_BACKUP" = true ] && echo -e "${GREEN}[✓]${NC}" || echo -e "${RED}[ ]${NC}")"
    echo ""
    echo -e "${CYAN}Quick Select:${NC}"
    echo -e "  ${BOLD}a${NC}) Select All"
    echo -e "  ${BOLD}c${NC}) Core Only (Hyprland, Rofi, Waybar, Themes)"
    echo -e "  ${BOLD}n${NC}) None"
    echo ""
    echo -e "${GREEN}  i${NC}) ${BOLD}Install${NC}"
    echo -e "${RED}  q${NC}) Quit"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

toggle_option() {
    case $1 in
        1) INSTALL_HYPRLAND=$([ "$INSTALL_HYPRLAND" = true ] && echo false || echo true) ;;
        2) INSTALL_ROFI=$([ "$INSTALL_ROFI" = true ] && echo false || echo true) ;;
        3) INSTALL_WAYBAR=$([ "$INSTALL_WAYBAR" = true ] && echo false || echo true) ;;
        4) INSTALL_THEMES=$([ "$INSTALL_THEMES" = true ] && echo false || echo true) ;;
        5) INSTALL_KITTY=$([ "$INSTALL_KITTY" = true ] && echo false || echo true) ;;
        6) INSTALL_FASTFETCH=$([ "$INSTALL_FASTFETCH" = true ] && echo false || echo true) ;;
        7) INSTALL_NVIM=$([ "$INSTALL_NVIM" = true ] && echo false || echo true) ;;
        8) INSTALL_MISC=$([ "$INSTALL_MISC" = true ] && echo false || echo true) ;;
        9) CREATE_BACKUP=$([ "$CREATE_BACKUP" = true ] && echo false || echo true) ;;
    esac
}

select_all() {
    INSTALL_HYPRLAND=true
    INSTALL_ROFI=true
    INSTALL_WAYBAR=true
    INSTALL_THEMES=true
    INSTALL_KITTY=true
    INSTALL_FASTFETCH=true
    INSTALL_NVIM=true
    INSTALL_MISC=true
}

select_core() {
    INSTALL_HYPRLAND=true
    INSTALL_ROFI=true
    INSTALL_WAYBAR=true
    INSTALL_THEMES=true
}

select_none() {
    INSTALL_HYPRLAND=false
    INSTALL_ROFI=false
    INSTALL_WAYBAR=false
    INSTALL_THEMES=false
    INSTALL_KITTY=false
    INSTALL_FASTFETCH=false
    INSTALL_NVIM=false
    INSTALL_MISC=false
}

interactive_menu() {
    while true; do
        show_menu
        read -p "Select option: " -n 1 -r choice
        echo ""
        
        case $choice in
            1|2|3|4|5|6|7|8|9)
                toggle_option "$choice"
                ;;
            a|A)
                select_all
                ;;
            c|C)
                select_core
                ;;
            n|N)
                select_none
                ;;
            i|I)
                # Check if at least one component is selected
                if [ "$INSTALL_HYPRLAND" = false ] && [ "$INSTALL_ROFI" = false ] && \
                   [ "$INSTALL_WAYBAR" = false ] && [ "$INSTALL_THEMES" = false ] && \
                   [ "$INSTALL_KITTY" = false ] && [ "$INSTALL_FASTFETCH" = false ] && \
                   [ "$INSTALL_NVIM" = false ] && [ "$INSTALL_MISC" = false ]; then
                    echo ""
                    print_warning "Please select at least one component to install!"
                    echo ""
                    read -p "Press any key to continue..." -n 1 -r
                    continue
                fi
                return 0
                ;;
            q|Q)
                echo ""
                print_info "Installation cancelled by user"
                exit 0
                ;;
            *)
                ;;
        esac
    done
}

# ============================================================================
# Main Installation Process
# ============================================================================

run_installation() {
    clear
    show_banner
    
    print_step "Starting installation process"
    echo ""
    
    # Check dependencies
    if ! check_dependencies; then
        print_error "Dependency check failed. Aborting installation."
        exit 1
    fi
    
    # Create backup
    create_backup
    
    # Install selected components
    local total_steps=0
    local current_step=0
    
    # Count total steps
    [ "$INSTALL_HYPRLAND" = true ] && ((total_steps++))
    [ "$INSTALL_ROFI" = true ] && ((total_steps++))
    [ "$INSTALL_WAYBAR" = true ] && ((total_steps++))
    [ "$INSTALL_KITTY" = true ] && ((total_steps++))
    [ "$INSTALL_FASTFETCH" = true ] && ((total_steps++))
    [ "$INSTALL_NVIM" = true ] && ((total_steps++))
    [ "$INSTALL_MISC" = true ] && ((total_steps++))
    [ "$INSTALL_THEMES" = true ] && ((total_steps++))
    
    # Install components
    if [ "$INSTALL_HYPRLAND" = true ]; then
        ((current_step++))
        install_hyprland_config
    fi
    
    if [ "$INSTALL_ROFI" = true ]; then
        ((current_step++))
        install_rofi_config
    fi
    
    if [ "$INSTALL_WAYBAR" = true ]; then
        ((current_step++))
        install_waybar_config
    fi
    
    if [ "$INSTALL_KITTY" = true ]; then
        ((current_step++))
        install_kitty_config
    fi
    
    if [ "$INSTALL_FASTFETCH" = true ]; then
        ((current_step++))
        install_fastfetch_config
    fi
    
    if [ "$INSTALL_NVIM" = true ]; then
        ((current_step++))
        install_nvim_config
    fi
    
    if [ "$INSTALL_MISC" = true ]; then
        ((current_step++))
        install_misc_configs
    fi
    
    if [ "$INSTALL_THEMES" = true ]; then
        ((current_step++))
        install_themes_and_wallpapers
    fi
    
    # Fix absolute paths
    fix_absolute_paths
    
    # Installation complete
    echo ""
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    print_success "Installation completed successfully!"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    print_info "Configuration files installed to: $CONFIG_DIR"
    
    if [ "$CREATE_BACKUP" = true ] && [ -d "$BACKUP_DIR" ]; then
        print_info "Backup created at: $BACKUP_DIR"
    fi
    
    echo ""
    echo -e "${YELLOW}${BOLD}Next Steps:${NC}"
    echo -e "  1. Log out and log back into Hyprland"
    echo -e "  2. Press Super+R to open the main menu"
    echo -e "  3. Use Super+P to select a theme and wallpaper"
    echo ""
    
    if [ "$INSTALL_THEMES" = true ]; then
        print_info "Wallpapers installed to: $USER_HOME/.local/share/wallpapers"
    fi
    
    echo ""
    echo -e "${CYAN}${BOLD}Absolute Paths Fixed:${NC}"
    echo -e "  • Waybar colors path: $USER_HOME/.cache/wal/colors-waybar.css"
    echo -e "  • Screenshot directory: $USER_HOME/Pictures/screenshots"
    echo -e "  • Wallpaper directory: $USER_HOME/.local/share/wallpapers"
    echo -e "  • Music directory: $USER_HOME/Music"
    echo ""
    
    echo -e "${BLUE}Enjoy your new dotfiles! 🎉${NC}"
    echo ""
}

# ============================================================================
# Entry Point
# ============================================================================

main() {
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root!"
        exit 1
    fi
    
    # Show interactive menu
    interactive_menu
    
    # Confirm installation
    echo ""
    print_warning "This will install the selected dotfiles to $CONFIG_DIR"
    read -p "Continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi
    
    # Run installation
    run_installation
}

# Run main function
main
