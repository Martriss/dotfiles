# Performance optimization: Install Zinit if not present
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d $ZINIT_HOME ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# Enable Powerlevel10k instant prompt (optional but very fast)
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# PATH settings (no change needed)
export PATH=$PATH:$HOME/go/bin

# Editor setting
export EDITOR=nvim

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

# Keybindings
bindkey -e # Mode Emacs
zle_highlight+=(paste:none)

# Dotfiles in completion
setopt globdots

# Basic aliases
alias py='python3'
alias ls='ls --color'

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

# Starship prompt (load directly for reliability)
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Alternative: use Zinit to load it (commented out)
# zinit ice wait"0" lucid
# zinit snippet /dev/null
# zinit ice wait"0" lucid atload'eval "$(starship init zsh)"'
# zinit snippet /dev/null

# Nvim config prompt function (already efficient)
vv() {
  # Assumes all configs exist in directories named ~/.config/nvim-*
  local config=$(fd --max-depth 1 --glob 'nvim-*' ~/.config | fzf --prompt="Neovim Configs > " --height=~50% --layout=reverse --border --exit-0)
 
  # If I exit fzf without selecting a config, don't open Neovim
  [[ -z $config ]] && echo "No config selected" && return
 
  # Open Neovim with the selected config
  NVIM_APPNAME=$(basename $config) nvim $@
}

# Completion keybindings and options
# Tab completion configuration
bindkey '^I' complete-word        # tab to complete
bindkey '^[[Z' reverse-menu-complete  # shift-tab to reverse complete

# Completion menu navigation with arrow keys
zmodload zsh/complist
bindkey -M menuselect '^h' vi-backward-char
bindkey -M menuselect '^j' vi-down-line-or-history
bindkey -M menuselect '^k' vi-up-line-or-history
bindkey -M menuselect '^l' vi-forward-char
bindkey -M menuselect '^[[A' vi-up-line-or-history    # Up arrow
bindkey -M menuselect '^[[B' vi-down-line-or-history  # Down arrow
bindkey -M menuselect '^[[C' vi-forward-char          # Right arrow
bindkey -M menuselect '^[[D' vi-backward-char         # Left arrow

# Useful keybindings for accepting/canceling completion
bindkey -M menuselect '^M' .accept-line               # Enter to accept
bindkey -M menuselect '^G' send-break                 # Ctrl+G to cancel
bindkey -M menuselect '^O' accept-and-infer-next-history  # Ctrl+O to accept and show next

# Additional completion settings for better user experience
zstyle ':completion:*' special-dirs true              # Complete special directories
zstyle ':completion:*' list-separator '-->'           # Separator in completion lists
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'  # Color process list
zstyle ':completion:*' accept-exact '*(N)'           # Don't require exact match if there is none

# Configure completions (moved to the bottom for better performance)
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:messages' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- No matches found --%f'
zstyle ':completion:*:corrections' format '%F{yellow}-- %d (errors: %e) --%f'
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

# Function to create directory and cd into it
mkcd() {
  mkdir -p "$@" && cd "$@"
}

