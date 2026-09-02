command -v pfetch >/dev/null && pfetch

# Homebrew is the only source for Antidote in this image.
[[ -r /home/linuxbrew/.linuxbrew/opt/antidote/share/antidote/antidote.zsh ]] && \
  source /home/linuxbrew/.linuxbrew/opt/antidote/share/antidote/antidote.zsh && \
  antidote load

autoload -Uz compinit && compinit

setopt AUTO_CD

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY

bindkey '\e[1;2D' backward-word
bindkey '\e[1;2C' forward-word
bindkey '\e[1;5D' beginning-of-line
bindkey '\e[1;5C' end-of-line
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

ZSH_AUTOSUGGEST_STRATEGY=(history)

if (( $+commands[fzf] )) && [[ -t 0 ]]; then
  source <(fzf --zsh)
fi

typeset -U path PATH
path=($HOME/bin $HOME/.local/bin $path)

export EDITOR=micro
export VISUAL=micro
export MANPAGER="less -R"

alias ls="${aliases[ls]:-ls} --color=auto -A"
alias cat="bat --theme=base16 --paging=never"

eval "$(starship init zsh)"
