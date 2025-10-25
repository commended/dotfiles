if [[ -f ~/.cache/wal/sequences ]]; then
    cat ~/.cache/wal/sequences
else
    echo 'pywal color sequences not found!'
    return 1
fi

if [[ -f /etc/zshrc ]]; then
    source /etc/zshrc
elif [[ -f /etc/zsh/zshrc ]]; then
    source /etc/zsh/zshrc
fi

if [[ -d ~/.zshrc.d ]]; then
    for rc in ~/.zshrc.d/*; do
        if [[ -f "$rc" ]]; then
            source "$rc"
        fi
    done
fi
unset rc

alias ff='clear && fastfetch'
alias clock='tty-clock -c -C 7 -s -n -t'
alias pipes='pipes.sh'
alias ocean='asciiquarium'
alias bonzai='cbonsai -l -m aug!'
alias shell='nvim ~/.zshrc'
alias update='sudo nixos-rebuild switch --flake /etc/nixos#hyprland'
alias dott='~/.cargo/bin/dott-tui'
alias gifd='~/.cargo/bin/gifd'

export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland

eval "$(starship init zsh)"

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
