if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

autoload -U compinit
compinit -i

autoload -U select-word-style
select-word-style bash

export PATH=$PATH:$HOME/go/bin
alias py='python3'
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/mrisser/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/mrisser/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/mrisser/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/mrisser/google-cloud-sdk/completion.zsh.inc'; fi

bindkey "\e[1;3D" backward-word         # ⌥←
bindkey "\e[1;3C" forward-word          # ⌥→
bindkey "^[[1;9D" beginning-of-line     # cmd+←
bindkey "^[[1;9C" end-of-line           # cmd+→
bindkey '^[[1K^[[1G' kill-whole-line    # cmd+⌫ (sequence from kitty)
bindkey '\e[3^' kill-line               # ⌥+cmd+⌫ (sequence from kitty)

vv() {
  # Assumes all configs exist in directories named ~/.config/nvim-*
  local config=$(fd --max-depth 1 --glob 'nvim-*' ~/.config | fzf --prompt="Neovim Configs > " --height=~50% --layout=reverse --border --exit-0)
 
  # If I exit fzf without selecting a config, don't open Neovim
  [[ -z $config ]] && echo "No config selected" && return
 
  # Open Neovim with the selected config
  NVIM_APPNAME=$(basename $config) nvim $@
}

source <(fzf --zsh)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
