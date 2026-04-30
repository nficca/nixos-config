#!/usr/bin/env bash

data=$(cat)

model=$(echo "$data" | jq -r '.model.display_name // "?"')
used=$(echo "$data" | jq -r '.context_window.used_percentage // 0 | floor')
cost=$(echo "$data" | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(echo "$data" | jq -r '.cost.total_duration_ms // 0 | floor')

# Context color: green < 50%, yellow 50-75%, red > 75%
if (( used > 75 )); then
  color="\033[31m"
elif (( used > 50 )); then
  color="\033[33m"
else
  color="\033[32m"
fi
reset="\033[0m"

# Progress bar
bar_width=15
filled=$((used * bar_width / 100))
empty=$((bar_width - filled))
bar=""
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done

# Format cost
cost_fmt=$(printf '$%.2f' "$cost")

# Format duration
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

echo -e "${color}${model}${reset} ${color}${bar}${reset} ${used}% │ ${cost_fmt} │ ${duration_fmt}"
