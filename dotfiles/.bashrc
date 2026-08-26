# Non-interactive shells get nothing
[[ $- != *i* ]] && return

# bash-completion
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi

# fzf: keybindings and completion (Ctrl+R, Ctrl+T, Alt+C)
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"
    export FZF_DEFAULT_OPTS="
        --color=bg+:#282a2e,bg:#1d1f21,spinner:#f0c674,hl:#cc6666
        --color=fg:#c5c8c6,header:#81a2be,info:#8abeb7,pointer:#f0c674
        --color=marker:#b5bd68,fg+:#c5c8c6,prompt:#f0c674,hl+:#cc6666
        --height 40% --border rounded
    "
    # Use fd for fzf file finding if available
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi

# zoxide: smart directory jumping (z, zi)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# bat: theming only, no aliases
if command -v bat &>/dev/null; then
    export BAT_THEME="base16"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# History settings
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%F %T  "
shopt -s histappend
shopt -s cmdhist

# Shell options
shopt -s checkwinsize
shopt -s globstar
shopt -s autocd
shopt -s cdspell

# Show fastfetch on first login (not on every subshell)
if [[ -z "$SECTLY_SHELL_GREETED" ]] && command -v fastfetch &>/dev/null; then
    export SECTLY_SHELL_GREETED=1
    fastfetch
fi
