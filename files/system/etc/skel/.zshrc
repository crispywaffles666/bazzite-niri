# priorities
pfetch

# antidote
source /home/linuxbrew/.linuxbrew/opt/antidote/share/antidote/antidote.zsh
antidote load

# completions
autoload -Uz compinit && compinit

# navigation
setopt AUTO_CD

# history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY

# keybinds
bindkey '\e[1;2D' backward-word
bindkey '\e[1;2C' forward-word
bindkey '\e[1;5D' beginning-of-line
bindkey '\e[1;5C' end-of-line
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history)

# fzf
if (( $+commands[fzf] )) && [[ -t 0 ]]; then
  source <(fzf --zsh)
fi

# PATH
typeset -U path PATH
path=($HOME/bin $HOME/.local/bin $HOME/.cargo/bin $HOME/.npm-global/bin $path)

# env vars
export EDITOR=nvim
export MANPAGER="nvim +Man!"
export ANDROID_HOME=$HOME/Android/Sdk

# aliases
alias yay="paru"
alias ls="${aliases[ls]:-ls} --color=auto -A"
# alias fastfetch='/usr/bin/fastfetch -c ~/.config/fastfetch/fastfetch.jsonc'
# alias neofetch='/usr/bin/fastfetch -c ~/.config/fastfetch/fastfetch.jsonc'
alias cat="bat --theme=base16 --paging=never"

ivpn-connect() {
  ivpn connect -fastest -protocol WireGuard &&
    sudo resolvectl dnsovertls wgivpn no &&
    sudo resolvectl domain wgivpn "~."
}

# prompt
eval "$(starship init zsh)"

# kimi-code
export PATH="/home/user/.kimi-code/bin:$PATH"
