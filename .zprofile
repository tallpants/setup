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

# Home directory bin
export PATH=$PATH:$HOME/bin

# copy file to clipboard
filecopy() {
  emulate -L zsh
  (( $# )) || { print -u2 "usage: filecopy <file>"; return 1 }
  local f=${1:a}                     # :a = absolutize, keeps symlinks intact
  [[ -e $f ]] || { print -u2 "filecopy: no such file: $f"; return 1 }
  osascript -e 'on run argv' \
            -e 'set the clipboard to (POSIX file (item 1 of argv))' \
            -e 'end run' "$f" >/dev/null
}
