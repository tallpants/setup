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
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
TOKENS=$(echo "$input" | jq -r '[.context_window.current_usage.input_tokens, .context_window.current_usage.cache_creation_input_tokens, .context_window.current_usage.cache_read_input_tokens] | map(. // 0) | add')
RL_HAS=$(echo "$input" | jq -r '(.rate_limits.five_hour.resets_at // .rate_limits.seven_day.resets_at) != null')
RL_5H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0' | cut -d. -f1)
RL_5H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // 0')
RL_7D_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0' | cut -d. -f1)
RL_7D_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // 0')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'
TRACK='\033[48;5;238m'  # bar track (unfilled) background

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

# Render a 10-cell bar with eighth-block sub-cell resolution, so usage below
# 10% still shows a partial block instead of flooring to an empty bar.
make_bar() {
  local pct=$1 width=10 eighths filled rem i out=""
  [ "$pct" -gt 100 ] && pct=100
  [ "$pct" -lt 0 ] && pct=0
  eighths=$((pct * width * 8 / 100))
  filled=$((eighths / 8)); rem=$((eighths % 8))
  local partials=("" "▏" "▎" "▍" "▌" "▋" "▊" "▉")
  for ((i=0; i<width; i++)); do
    if [ "$i" -lt "$filled" ]; then out+="█"
    elif [ "$i" -eq "$filled" ] && [ "$rem" -gt 0 ]; then out+="${partials[$rem]}"
    else out+=" "; fi
  done
  printf '%s' "$out"
}
BAR=$(make_bar "$PCT")

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
  RL_5H_BAR=$(make_bar "$RL_5H_PCT"); RL_7D_BAR=$(make_bar "$RL_7D_PCT")
  RL_5H_FMT="5H: ${TRACK}$(rl_color "$RL_5H_PCT")${RL_5H_BAR}${RESET} ${RL_5H_PCT}% ($(fmt_reset "$RL_5H_RESET"))"
  RL_7D_FMT="7D: ${TRACK}$(rl_color "$RL_7D_PCT")${RL_7D_BAR}${RESET} ${RL_7D_PCT}% ($(fmt_reset "$RL_7D_RESET"))"
  RL_SECTION=" | ${RL_5H_FMT} | ${RL_7D_FMT}"
fi

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌳 $(git branch --show-current 2>/dev/null)"

# Active Doppler config for the current dir, mirroring the `sorindoppler` zsh
# prompt theme: find the longest path-prefix scope in ~/.doppler/.doppler.yaml
# and show "<enclave.project>/<enclave.config>". Absent when no scope matches.
DOPPLER=""
DOPPLER_YAML="$HOME/.doppler/.doppler.yaml"
if [ -r "$DOPPLER_YAML" ]; then
  DOPPLER_INFO=$(awk -v pwd="$DIR" '
    /^    \// {
      key = $0
      sub(/^    /, "", key)
      sub(/:$/, "", key)
      current_key = key
      # Match exact dir or any descendant. Excludes the bare "/" scope, which
      # is not a real prefix match (no "//" at start of pwd).
      if (key == pwd || index(pwd "/", key "/") == 1) {
        matches[key] = 1
      }
      next
    }
    current_key in matches && /enclave\.project:/ { proj[current_key] = $2 }
    current_key in matches && /enclave\.config:/  { cfg[current_key]  = $2 }
    END {
      best = ""
      for (k in matches) {
        if (length(k) > length(best)) best = k
      }
      if (best == "") exit
      if ((best in proj) && (best in cfg)) print proj[best] "/" cfg[best]
      else if (best in proj) print proj[best]
      else if (best in cfg)  print cfg[best]
    }
  ' "$DOPPLER_YAML")
  [ -n "$DOPPLER_INFO" ] && DOPPLER=" | ⚙️ ${DOPPLER_INFO}"
fi

echo -e "📁 ${DIR_SHORT}$BRANCH$DOPPLER"
echo -e "Context: ${TRACK}${BAR_COLOR}${BAR}${RESET} ${TOKENS_FMT} (${PCT}%)${RL_SECTION}"
