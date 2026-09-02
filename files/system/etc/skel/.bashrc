prepend_path() {
  [[ ":$PATH:" == *":$1:"* ]] || PATH="$1:$PATH"
}

prepend_path "$HOME/bin"
prepend_path "$HOME/.local/bin"
export PATH

export EDITOR=micro
export VISUAL=micro
export MANPAGER="less -R"

[[ $- != *i* ]] && return

# ble.sh owns these hooks in interactive shells.
PROMPT_COMMAND=()
PS0=

command -v pfetch >/dev/null && pfetch

[[ -r /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

shopt -s autocd

HISTFILE=~/.bash_history
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoredups
shopt -s histappend

bind '"\e[1;2D": backward-word'
bind '"\e[1;2C": forward-word'
bind '"\e[1;5D": beginning-of-line'
bind '"\e[1;5C": end-of-line'

alias ls='ls --color=auto -A'
alias grep='grep --color=auto'
alias fastfetch='/usr/bin/fastfetch -c ~/.config/fastfetch/fastfetch.jsonc'
alias neofetch='/usr/bin/fastfetch -c ~/.config/fastfetch/fastfetch.jsonc'
alias cat="bat --theme=base16 --paging=never"

eval "$(starship init bash)"

eval "$(fzf --bash)"
[[ $BLE_VERSION ]] || [[ ! -r ~/.local/share/blesh/ble.sh ]] || source ~/.local/share/blesh/ble.sh --attach=prompt
