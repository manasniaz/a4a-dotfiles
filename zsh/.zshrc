# zsh for interactive shells. Plugins come from the official Arch packages, not a
# framework (no oh-my-zsh). Colours come from the wallpaper palette, rendered by
# matugen into ~/.cache/a4a/zsh-colors.zsh.

[[ -o interactive ]] || return

export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY AUTO_CD

# Completion, cached under ~/.cache rather than in the home folder.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

alias ls='ls --color=auto'
alias ll='ls -lh'
alias grep='grep --color=auto'

# Grey ghost text of the last matching command, accepted with the right arrow.
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# Must be sourced after everything that binds keys. Colours are set after it, below.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ -f ~/.cache/a4a/zsh-colors.zsh ]] && source ~/.cache/a4a/zsh-colors.zsh

# The prompt: starship, coloured from the palette (~/.config/starship.toml).
eval "$(starship init zsh)"

# fastfetch greets each new kitty window. Only there, so scripts and ssh stay quiet.
if [[ -n $KITTY_WINDOW_ID ]] && (( $+commands[fastfetch] )); then
    fastfetch -c ~/.config/fastfetch/config.jsonc
fi
