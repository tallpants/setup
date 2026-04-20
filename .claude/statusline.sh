#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
DIR="${DIR%/}"

shrink_path() {
  local path="$1" prefix
  if [[ "$path" == "$HOME" ]]; then echo "~"; return; fi
  if [[ "$path" == "$HOME/"* ]]; then
    path="${path#$HOME/}"; prefix="~/"
  elif [[ "$path" == /* ]]; then
    path="${path#/}"; prefix="/"
  fi
  local IFS='/' parts result="" i n
  read -ra parts <<< "$path"
  n=${#parts[@]}
  for ((i=0; i<n; i++)); do
    local p="${parts[$i]}"
    if [[ $i -eq $((n-1)) ]]; then
      result+="$p"
    elif [[ "$p" == .* ]]; then
      result+="${p:0:2}/"
    else
      result+="${p:0:1}/"
    fi
  done
  echo "${prefix}${result}"
}
DIR_SHORT=$(shrink_path "$DIR")
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
TOKENS=$(echo "$input" | jq -r '[.context_window.current_usage.input_tokens, .context_window.current_usage.cache_creation_input_tokens, .context_window.current_usage.cache_read_input_tokens] | map(. // 0) | add')
RL_HAS=$(echo "$input" | jq -r '(.rate_limits.five_hour.resets_at // .rate_limits.seven_day.resets_at) != null')
RL_5H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0' | cut -d. -f1)
RL_5H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // 0')
RL_7D_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0' | cut -d. -f1)
RL_7D_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // 0')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

if [ "$TOKENS" -ge 1000 ]; then
  TOKENS_FMT=$(awk -v t="$TOKENS" 'BEGIN{printf "%.1fk", t/1000}')
else
  TOKENS_FMT="$TOKENS"
fi

fmt_reset() {
  local target=$1 now diff
  now=$(date +%s)
  diff=$((target - now))
  if [ "$diff" -le 0 ]; then echo "now"; return; fi
  if [ "$diff" -ge 86400 ]; then echo "$((diff / 86400))d"
  elif [ "$diff" -ge 3600 ]; then echo "$((diff / 3600))h"
  else echo "$((diff / 60))m"; fi
}

rl_color() {
  if [ "$1" -ge 90 ]; then printf '%b' "$RED"
  elif [ "$1" -ge 70 ]; then printf '%b' "$YELLOW"
  else printf '%b' "$GREEN"; fi
}

RL_SECTION=""
if [ "$RL_HAS" = "true" ]; then
  RL_5H_FMT="$(rl_color "$RL_5H_PCT")5H:${RL_5H_PCT}%-$(fmt_reset "$RL_5H_RESET")${RESET}"
  RL_7D_FMT="$(rl_color "$RL_7D_PCT")7H:${RL_7D_PCT}%-$(fmt_reset "$RL_7D_RESET")${RESET}"
  RL_SECTION=" | ${RL_5H_FMT} ${RL_7D_FMT}"
fi

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌳 $(git branch --show-current 2>/dev/null)"

COST_FMT=$(printf '$%.2f' "$COST")
echo -e "📁 ${DIR_SHORT}$BRANCH"
# echo -e "${CYAN}$MODEL${RESET} | ${BAR_COLOR}${BAR}${RESET} ${TOKENS_FMT} (${PCT}%) | ${YELLOW}${COST_FMT}${RESET}"
echo -e "${BAR_COLOR}${BAR}${RESET} ${TOKENS_FMT} (${PCT}%) | ${YELLOW}${COST_FMT}${RESET}${RL_SECTION}"
