# CD into directory containing file found with fzf
cdfzf() { file="$(fzf)"; [ -n "$file" ] && cd "$(dirname "$file")"; }

# zoxide
eval "$(zoxide init zsh)"

# Claude Code YOLO mode alias
alias cy="claude --dangerously-skip-permissions"

# Claude Code quick inline prompt with Haiku (e.g `cyhp "do something")
alias cyhp="claude --model haiku --dangerously-skip-permissions -p"
