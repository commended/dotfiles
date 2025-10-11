# .zshrc

# Prioritized: pywal colors, kitty config, and ffh
if [[ -f ~/.cache/wal/sequences ]]; then
    cat ~/.cache/wal/sequences
else
    echo 'pywal color sequences not found!'
    return 1
fi


# Always set up Kitty config and aliases
alias kitty-config='$EDITOR ~/.config/kitty/kitty.conf'
alias term='kitty'
alias terminal='kitty'
export TERMINAL=kitty
export KITTY_CONFIG_DIRECTORY=~/.config/kitty
export KITTY_CONFIG_FILE=~/.config/kitty/kitty.conf

# Fastfetch configuration
alias ff='fastfetch'
alias ffm='fastfetch --config ~/.config/fastfetch/config-minimal.jsonc'
alias ffnl='fastfetch --config ~/.config/fastfetch/config-nologo.jsonc'
alias ffh='clear && fastfetch --config ~/.config/fastfetch/config-hyprland.jsonc'
alias personalfetch='/usr/local/bin/afetch' #WORK IN PROGRESS
alias animatedfetch='brrtfetch /home/aug/Downloads/ricing/terninal/debian.gif'


# Source global definitions (zsh equivalent)
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

# Source additional configuration files from ~/.zshrc.d (zsh equivalent of ~/.bashrc.d)
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
alias ocean='asciiquarium'
alias bonzai='cbonsai -l -m aug!'
alias project='/home/aug/projects/mp3_player.sh'
alias music='~/.cargo/bin/rmpc'
alias basalt='/home/aug/.cargo/bin/basalt'
alias koto='/home/aug/.cargo/bin/kotofetch'
alias dotter='/home/aug/.cargo/bin/dotter'
alias shell='nvim ~/.zshrc'


# Desktop Environment: Hyprland only
PS1="> "
alias waybar-reload='killall waybar && waybar &'
alias hypr-reload='hyprctl reload'
alias hypr-config='$EDITOR ~/.config/hypr/hyprland.conf'
alias wofi-run='wofi --show drun'
alias file-manager='thunar . &'
alias screenshot='grim ~/Pictures/screenshot-$(date +%Y%m%d_%H%M%S).png'
alias screenshot-area='grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d_%H%M%S).png'
alias wallpaperswitcher='wallpaper-selector'

# Hyprland environment variables
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland

# Initialize starship prompt (same as bash)
eval "$(starship init zsh)"

# Zsh performance optimizations and features
setopt AUTO_CD                # cd just by typing directory name
setopt CORRECT                # spelling correction
setopt HIST_VERIFY            # verify history expansion before executing
setopt SHARE_HISTORY          # share history between sessions
setopt APPEND_HISTORY         # append to history file
setopt INC_APPEND_HISTORY     # add commands to history immediately
setopt HIST_IGNORE_DUPS       # ignore duplicate commands
setopt HIST_REDUCE_BLANKS     # remove superfluous blanks
setopt NO_BEEP                # disable beep

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Fast completion system with caching
autoload -Uz compinit
# Only regenerate compdump once a day for performance
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Enable completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
