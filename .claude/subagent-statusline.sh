#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
TOKENS=$(echo "$input" | jq -r '[.context_window.current_usage.input_tokens, .context_window.current_usage.cache_creation_input_tokens, .context_window.current_usage.cache_read_input_tokens] | map(. // 0) | add')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

if [ "$PCT" -ge 90 ]; then PCT_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then PCT_COLOR="$YELLOW"
else PCT_COLOR="$GREEN"; fi

if [ "$TOKENS" -ge 1000 ]; then
  TOKENS_FMT=$(awk -v t="$TOKENS" 'BEGIN{printf "%.1fk", t/1000}')
else
  TOKENS_FMT="$TOKENS"
fi

COST_FMT=$(printf '$%.2f' "$COST")
echo -e "${CYAN}[$MODEL]${RESET} | ${PCT_COLOR}${TOKENS_FMT} (${PCT}%)${RESET} | ${YELLOW}${COST_FMT}${RESET}"
