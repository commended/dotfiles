if [[ -f /etc/zshrc ]]; then
    source /etc/zshrc
elif [[ -f /etc/zsh/zshrc ]]; then
    source /etc/zsh/zshrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

if [[ -d ~/.zshrc.d ]]; then
    for rc in ~/.zshrc.d/*; do
        if [[ -f "$rc" ]]; then
            source "$rc"
        fi
    done
fi
unset rc

# Common aliases and settings
alias clock='tty-clock -c -C 7 -s -n'
alias pipes='pipes.sh'
alias ff='fastfetch'
alias ffm='fastfetch --config ~/.config/fastfetch/config-minimal.jsonc'
alias ffnl='ff --config ~/.config/fastfetch/config-nologo.jsonc'
alias ffh='ff --config ~/.config/fastfetch/config-hyprland.jsonc'
alias ocean='asciiquarium'
alias yazi='flatpak run io.github.sxyazi.yazi'
alias bonzai='cbonsai -l -m aug!'

# Import pywal colors
if [[ -f ~/.cache/wal/sequences ]]; then
    (cat ~/.cache/wal/sequences &)
fi

# Desktop Environment specific configurations
if [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]] || [[ "$XDG_CURRENT_DESKTOP" == *"plasma"* ]]; then
    # KDE Plasma-specific settings
    export PS1="> "
    alias dolphin-here='dolphin . &'
    alias kde-theme='lookandfeeltool -l'
    alias plasma-theme='plasma-theme -l'
    
    # KDE Kitty configuration
    if command -v kitty >/dev/null 2>&1; then
        alias kitty-config='$EDITOR ~/.config/kitty/kitty.conf'
        alias term='kitty'
        alias terminal='kitty'
        export TERMINAL=kitty
        export KITTY_CONFIG_FILE=~/.config/kitty/kitty.conf
    fi
    
    # KDE-specific fastfetch on login
    ff

elif [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]] || [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    # Hyprland-specific settings
    PS1="> "
    alias waybar-reload='killall waybar && waybar &'
    alias hypr-reload='hyprctl reload'
    alias hypr-config='$EDITOR ~/.config/hypr/hyprland.conf'
    alias wofi-run='wofi --show drun'
    alias file-manager='thunar . &'
    alias screenshot='grim ~/Pictures/screenshot-$(date +%Y%m%d_%H%M%S).png'
    alias screenshot-area='grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d_%H%M%S).png'
    alias wallpaperswitcher='wallpaper-selector'
    
    # Hyprland Kitty configuration
    if command -v kitty >/dev/null 2>&1; then
        alias kitty-config='$EDITOR ~/.config/kitty/kitty-hyprland.conf'
        alias term='kitty'
        alias terminal='kitty'
        export TERMINAL=kitty
        export KITTY_CONFIG_DIRECTORY=~/.config/kitty
        export KITTY_CONFIG_FILE=~/.config/kitty/kitty-hyprland.conf
    fi
    
    # Hyprland environment variables
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM=wayland
    export XDG_SESSION_TYPE=wayland
    
    # Hyprland-specific fastfetch on login
    ffh

else
    # Default settings for other desktop environments
    export PS1="# "
    
    # Default Kitty configuration
    if command -v kitty >/dev/null 2>&1; then
        alias kitty-config='$EDITOR ~/.config/kitty/kitty.conf'
        alias term='kitty'
        alias terminal='kitty'
        export KITTY_CONFIG_FILE=~/.config/kitty/kitty.conf
    fi
    
    ffnl
fi

eval "$(starship init zsh)"

# Optional: Add some zsh-specific enhancements
# Uncomment these if you want to take advantage of zsh features

# Basic zsh options
# setopt AUTO_CD              # cd just by typing directory name
# setopt CORRECT              # spelling correction
# setopt HIST_VERIFY          # verify history expansion before executing
# setopt SHARE_HISTORY        # share history between sessions
# setopt APPEND_HISTORY       # append to history file
# setopt INC_APPEND_HISTORY   # add commands to history immediately

# History configuration
# HISTFILE=~/.zsh_history
# HISTSIZE=10000
# SAVEHIST=10000

# Enable completion system
# autoload -Uz compinit
# compinit
