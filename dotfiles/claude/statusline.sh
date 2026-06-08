#!/usr/bin/env bash

data=$(cat)

model=$(echo "$data" | jq -r '.model.display_name // "?" | split(" (")[0]')
ctx=$(echo "$data" | jq -r '.context_window.used_percentage // 0 | floor')
rl_5h=$(echo "$data" | jq -r '.rate_limits.five_hour.used_percentage // 0 | floor')
rl_5h_resets=$(echo "$data" | jq -r '.rate_limits.five_hour.resets_at // 0 | floor')
rl_7d=$(echo "$data" | jq -r '.rate_limits.seven_day.used_percentage // 0 | floor')
rl_7d_resets=$(echo "$data" | jq -r '.rate_limits.seven_day.resets_at // 0 | floor')
duration_ms=$(echo "$data" | jq -r '.cost.total_duration_ms // 0 | floor')

# Color helper: green < 50%, yellow 50-75%, red > 75%
color_for() {
  local val=$1
  if (( val > 75 )); then echo "\033[31m"
  elif (( val > 50 )); then echo "\033[33m"
  else echo "\033[32m"
  fi
}
reset="\033[0m"

ctx_color=$(color_for "$ctx")
rl5_color=$(color_for "$rl_5h")
rl7_color=$(color_for "$rl_7d")

# Format seconds remaining as human-readable time
fmt_remaining() {
  local resets_at=$1
  local now
  now=$(date +%s)
  local remaining=$((resets_at - now))
  if (( remaining <= 0 )); then
    echo "now"
    return
  fi
  if (( remaining >= 86400 )); then
    local d=$((remaining / 86400))
    local h=$(((remaining % 86400) / 3600))
    local m=$(((remaining % 3600) / 60))
    echo "${d}d${h}h${m}m"
  elif (( remaining >= 3600 )); then
    local h=$((remaining / 3600))
    local m=$(((remaining % 3600) / 60))
    echo "${h}h${m}m"
  elif (( remaining >= 60 )); then
    local m=$((remaining / 60))
    local s=$((remaining % 60))
    echo "${m}m${s}s"
  else
    echo "${remaining}s"
  fi
}

rl_5h_remaining=$(fmt_remaining "$rl_5h_resets")
rl_7d_remaining=$(fmt_remaining "$rl_7d_resets")

# Format session duration
duration_s=$((duration_ms / 1000))
if (( duration_s >= 3600 )); then
  h=$((duration_s / 3600))
  m=$(((duration_s % 3600) / 60))
  duration_fmt="${h}h${m}m"
elif (( duration_s >= 60 )); then
  m=$((duration_s / 60))
  s=$((duration_s % 60))
  duration_fmt="${m}m${s}s"
else
  duration_fmt="${duration_s}s"
fi

echo -e "${ctx_color}${model}${reset} ctx:${ctx_color}${ctx}%${reset} │ 5h:${rl5_color}${rl_5h}%${reset} ${rl_5h_remaining} │ 7d:${rl7_color}${rl_7d}%${reset} ${rl_7d_remaining} │ ${duration_fmt}"
