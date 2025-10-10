#!/usr/bin/env bash
# Installation script for the ricing configuration system

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Ricing Configuration System Installer         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo

# Check Python version
echo -e "${YELLOW}Checking Python installation...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 is not installed!${NC}"
    echo "  Please install Python 3.6 or later."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}✓ Python $PYTHON_VERSION found${NC}"

# Check PyYAML
echo -e "${YELLOW}Checking PyYAML...${NC}"
if ! python3 -c "import yaml" 2>/dev/null; then
    echo -e "${YELLOW}! PyYAML not found. Attempting to install...${NC}"
    
    if command -v pip3 &> /dev/null; then
        pip3 install --user pyyaml
    elif command -v pip &> /dev/null; then
        pip install --user pyyaml
    else
        echo -e "${RED}✗ pip not found! Please install PyYAML manually:${NC}"
        echo "  Arch:         sudo pacman -S python-yaml"
        echo "  Ubuntu/Debian: sudo apt install python3-yaml"
        echo "  Fedora:       sudo dnf install python3-pyyaml"
        echo "  pip:          pip install pyyaml"
        exit 1
    fi
fi

if python3 -c "import yaml" 2>/dev/null; then
    echo -e "${GREEN}✓ PyYAML is available${NC}"
else
    echo -e "${RED}✗ Failed to import PyYAML${NC}"
    exit 1
fi

# Create necessary directories
echo
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p "$HOME/.config/ricing"
mkdir -p "$HOME/.local/bin"
echo -e "${GREEN}✓ Directories created${NC}"

# Install config files
echo
echo -e "${YELLOW}Installing configuration files...${NC}"

# Check if user config already exists
if [[ -f "$HOME/.config/ricing/settings.yaml" ]]; then
    echo -e "${YELLOW}! settings.yaml already exists in ~/.config/ricing/${NC}"
    read -p "  Overwrite? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ln -sf "$SCRIPT_DIR/settings.yaml" "$HOME/.config/ricing/settings.yaml"
        echo -e "${GREEN}✓ settings.yaml linked${NC}"
    else
        echo -e "${BLUE}  Keeping existing settings.yaml${NC}"
    fi
else
    ln -s "$SCRIPT_DIR/settings.yaml" "$HOME/.config/ricing/settings.yaml"
    echo -e "${GREEN}✓ settings.yaml linked${NC}"
fi

# Install scripts
if [[ -f "$HOME/.local/bin/settings-manager" ]]; then
    ln -sf "$SCRIPT_DIR/settings-manager" "$HOME/.local/bin/settings-manager"
else
    ln -s "$SCRIPT_DIR/settings-manager" "$HOME/.local/bin/settings-manager"
fi
echo -e "${GREEN}✓ settings-manager linked to ~/.local/bin/${NC}"

if [[ -f "$HOME/.local/bin/open-settings" ]]; then
    ln -sf "$SCRIPT_DIR/open-settings" "$HOME/.local/bin/open-settings"
else
    ln -s "$SCRIPT_DIR/open-settings" "$HOME/.local/bin/open-settings"
fi
echo -e "${GREEN}✓ open-settings linked to ~/.local/bin/${NC}"

if [[ -f "$HOME/.local/bin/apply-settings" ]]; then
    ln -sf "$SCRIPT_DIR/apply-settings" "$HOME/.local/bin/apply-settings"
else
    ln -s "$SCRIPT_DIR/apply-settings" "$HOME/.local/bin/apply-settings"
fi
echo -e "${GREEN}✓ apply-settings linked to ~/.local/bin/${NC}"

# Check if ~/.local/bin is in PATH
echo
echo -e "${YELLOW}Checking PATH...${NC}"
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}! ~/.local/bin is not in your PATH${NC}"
    echo "  Add this to your ~/.bashrc or ~/.zshrc:"
    echo -e "  ${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
else
    echo -e "${GREEN}✓ ~/.local/bin is in PATH${NC}"
fi

# Hyprland keybinding reminder
echo
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  Installation Complete!                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${GREEN}Next steps:${NC}"
echo
echo "1. Add keybinding to Hyprland config (~/.config/hypr/hyprland.conf):"
echo -e "   ${BLUE}bind = SUPER, O, exec, open-settings${NC}"
echo
echo "2. Run the settings manager:"
echo -e "   ${BLUE}settings-manager${NC}"
echo
echo "3. Generate config snippets:"
echo -e "   ${BLUE}apply-settings${NC}"
echo
echo "4. View help:"
echo -e "   ${BLUE}settings-manager --help${NC}"
echo
echo -e "${YELLOW}Documentation:${NC} $SCRIPT_DIR/README.md"
echo
