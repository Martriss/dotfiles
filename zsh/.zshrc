# Performance optimization: Install Zinit if not present
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# PATH settings (no change needed)
export PATH=$PATH:$HOME/go/bin

# Editor setting
export EDITOR=nvim

# Define / and _ as word separator
WORDCHARS=${WORDCHARS/\/}
WORDCHARS=${WORDCHARS/\_}

# History settings (already well-configured)
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_reduce_blanks

# Keybindings
bindkey -e # Mode Emacs
zle_highlight+=(paste:none)

# Dotfiles in completion
setopt globdots

# Basic aliases
alias py='python3'
alias ls='eza --icons'                # Remplacé par eza avec icons
alias lsl='ls -a --long --header --git'  # Alias pour listing détaillé
alias la='ls -a'                      # Listing avec fichiers cachés
alias ..='cd ..'                      # Remonter d'un niveau
alias ...='cd ../..'                  # Remonter de deux niveaux
alias grep='grep --color=auto'        # Grep avec coloration
alias g='git'                         # Raccourci pour git
alias vim='nvim'                      # Utilise neovim par défaut

# Zinit plugin loading - everything in turbo mode for maximum performance
zinit wait lucid for \
  atinit"
    export NVM_DIR=$HOME/.nvm
    export NVM_LAZY_LOAD=true
    export NVM_COMPLETION=true
  " \
  lukechilds/zsh-nvm

# Homebrew (load in background)
zinit ice wait lucid
zinit snippet /dev/null
zinit ice wait lucid atload'[[ -f "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"'
zinit snippet /dev/null

# Google Cloud SDK (lazy-loaded via Zinit)
zinit ice wait"1" lucid
zinit snippet /dev/null
zinit ice wait"1" lucid atload'
  [[ -f "/Users/mrisser/google-cloud-sdk/path.zsh.inc" ]] && source "/Users/mrisser/google-cloud-sdk/path.zsh.inc"
  [[ -f "/Users/mrisser/google-cloud-sdk/completion.zsh.inc" ]] && source "/Users/mrisser/google-cloud-sdk/completion.zsh.inc"
'
zinit snippet /dev/null

# GHCup (lazy-loaded)
zinit ice wait"1" lucid
zinit snippet /dev/null
zinit ice wait"1" lucid atload'[[ -f "/Users/mrisser/.ghcup/env" ]] && source "/Users/mrisser/.ghcup/env"'
zinit snippet /dev/null

# FZF
zinit ice lucid wait has"fzf"
zinit snippet "https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh"
zinit snippet "https://github.com/junegunn/fzf/blob/master/shell/completion.zsh"

# Zoxide
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh --cmd cd)"
  alias cdi='cd -i'
fi

# Fast syntax highlighting (loads in background)
zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting

# Enhanced tab completion
zinit wait lucid for \
  atload"zicompinit; zicdreplay" \
  blockf \
  zsh-users/zsh-completions

# Autosuggestions (fish-like)
zinit wait lucid for \
  atload"!_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions

# Configuration minimaliste de la complétion
zstyle ':completion:*' menu select
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'

# Starship prompt
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Nvim config prompt function (already efficient)
vv() {
  # Assumes all configs exist in directories named ~/.config/nvim-*
  local config=$(fd --max-depth 1 --glob 'nvim-*' ~/.config | fzf --prompt="Neovim Configs > " --height=~50% --layout=reverse --border --exit-0)

  # If I exit fzf without selecting a config, don't open Neovim
  [[ -z $config ]] && echo "No config selected" && return

  # Open Neovim with the selected config
  NVIM_APPNAME=$(basename $config) nvim $@
}

# Function to create directory and cd into it
mkcd() {
  mkdir -p "$@" && cd "$@"
}

# Fonction serve - serveur web rapide dans le répertoire courant
serve() {
  local port="${1:-8000}"
  python3 -m http.server "$port"
}

# Fonction pour afficher le chemin d'accès de manière lisible
path() {
  echo $PATH | tr ':' '\n'
}
