# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Local bin path
export PATH="$HOME/.local/bin:$PATH"

# Neovim as default editor
export EDITOR="nvim"

# CD into directory containing file found with fzf
cdfzf() { file="$(fzf)"; [ -n "$file" ] && cd "$(dirname "$file")"; }

# zoxide
eval "$(zoxide init zsh)"
