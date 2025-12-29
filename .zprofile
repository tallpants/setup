# CD into directory containing file found with fzf
cdfzf() { file="$(fzf)"; [ -n "$file" ] && cd "$(dirname "$file")"; }

# zoxide
eval "$(zoxide init zsh)"

# Claude Code YOLO mode alias
alias cy="claude --dangerously-skip-permissions"
alias cyp="cy -p"

# Claude Code YOLO mode alias for Haiku with no thinking
alias cyh="MAX_THINKING_TOKENS=0 claude --model haiku --dangerously-skip-permissions"
alias cyhp="cyh -p"
