# CD into directory containing file found with fzf
cdfzf() { file="$(fzf)"; [ -n "$file" ] && cd "$(dirname "$file")"; }

# zoxide
eval "$(zoxide init zsh)"

# Claude Code YOLO mode alias
alias cy="claude --dangerously-skip-permissions"

# Claude Code quick inline prompt with Haiku with no thinking (e.g `cyhp "stage, commit, and push")
alias cyhp="MAX_THINKING_TOKENS=0 claude --model haiku --dangerously-skip-permissions -p"
